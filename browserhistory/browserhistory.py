#!/usr/bin/env python3
"""
browserhistory.py - Find browser history databases (SQLite) on the system and
print the last N visited URLs.

Supported: Firefox family (places.sqlite) and Chromium family (History file:
Chrome, Chromium, Brave, Edge, Opera, Vivaldi...), including snap/flatpak.

Must be run as root to read the profiles of all users.

Usage: sudo ./browserhistory.py [-n 10] [--per-file] (-a | -u login | dir ...)
       -a scans /home and /root (all users), -u scans the home of the user
"""

import argparse
import datetime
import os
import shutil
import sqlite3
import sys
import tempfile

CANDIDATE_NAMES = ("places.sqlite", "History")

# Firefox: visit_date = microseconds since 1970-01-01
SQL_FIREFOX = """
SELECT v.visit_date / 1000000.0, p.url, p.title
FROM moz_historyvisits v JOIN moz_places p ON p.id = v.place_id
ORDER BY v.visit_date DESC LIMIT ?
"""

# Chromium: visit_time = microseconds since 1601-01-01
SQL_CHROMIUM = """
SELECT (v.visit_time / 1000000.0) - 11644473600, u.url, u.title
FROM visits v JOIN urls u ON u.id = v.url
ORDER BY v.visit_time DESC LIMIT ?
"""


def find_candidates(dirs):
    for top in dirs:
        for root, subdirs, files in os.walk(top, followlinks=False):
            # Skip some heavy dirs that never hold browser profiles
            subdirs[:] = [d for d in subdirs if d not in ("node_modules", ".git", ".cache")]
            for name in files:
                if name in CANDIDATE_NAMES:
                    yield os.path.join(root, name)


def guess_browser(path):
    p = path.lower()
    for key, label in (("firefox", "Firefox"), ("librewolf", "LibreWolf"),
                       ("thunderbird", "Thunderbird"), ("brave", "Brave"),
                       ("microsoft-edge", "Edge"), ("vivaldi", "Vivaldi"),
                       ("opera", "Opera"), ("google-chrome", "Chrome"),
                       ("chromium", "Chromium")):
        if key in p:
            return label
    return "?"


def owner(path):
    try:
        import pwd
        return pwd.getpwuid(os.stat(path).st_uid).pw_name
    except (KeyError, OSError):
        return "?"


def query_db(path, limit):
    """Copy the DB (+ WAL/SHM, to get the latest entries) to a temp dir, since
    a running browser keeps it locked, then query the copy read-only."""
    tmpdir = tempfile.mkdtemp(prefix="bhist-")
    try:
        dst = os.path.join(tmpdir, "db.sqlite")
        shutil.copy2(path, dst)
        for ext in ("-wal", "-shm"):
            if os.path.exists(path + ext):
                shutil.copy2(path + ext, dst + ext)

        con = sqlite3.connect(dst)
        try:
            tables = {r[0] for r in con.execute(
                "SELECT name FROM sqlite_master WHERE type='table'")}
            if {"moz_places", "moz_historyvisits"} <= tables:
                sql = SQL_FIREFOX
            elif {"urls", "visits"} <= tables:
                sql = SQL_CHROMIUM
            else:
                return None  # Not a browser history DB
            return con.execute(sql, (limit,)).fetchall()
        finally:
            con.close()
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def fmt_ts(ts):
    try:
        return datetime.datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")
    except (OverflowError, OSError, ValueError, TypeError):
        return "?"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("-n", type=int, default=10, help="number of URLs (default 10)")
    ap.add_argument("--per-file", action="store_true",
                    help="show the last N URLs for each database instead of a global list")
    ap.add_argument("-u", "--user", metavar="LOGIN",
                    help="only scan the history of this user")
    ap.add_argument("-a", "--all", action="store_true",
                    help="scan all users (/home and /root)")
    ap.add_argument("dirs", nargs="*")
    args = ap.parse_args()

    if not (args.all or args.user or args.dirs):
        ap.print_help()
        sys.exit(1)

    uid = None
    if args.user:
        import pwd
        try:
            pw = pwd.getpwnam(args.user)
        except KeyError:
            sys.exit(f"Error: unknown user '{args.user}'")
        uid = pw.pw_uid
        if not args.dirs:
            args.dirs = [pw.pw_dir]
    if not args.dirs:
        args.dirs = ["/home", "/root"]

    if os.geteuid() != 0:
        print("Warning: not running as root, other users' profiles will be unreadable.",
              file=sys.stderr)

    allrows = []
    for path in find_candidates(args.dirs):
        if uid is not None:
            try:
                if os.stat(path).st_uid != uid:
                    continue
            except OSError:
                continue
        try:
            rows = query_db(path, args.n)
        except (sqlite3.Error, OSError) as e:
            print(f"Skip {path}: {e}", file=sys.stderr)
            continue
        if rows is None:
            continue
        user, browser = owner(path), guess_browser(path)
        print(f"Found {browser} history for {user}: {path} ({len(rows)} rows)", file=sys.stderr)
        rows = [(ts, user, browser, url, title) for ts, url, title in rows]
        if args.per_file:
            print(f"\n== {user} / {browser} - {path}")
            for ts, _, _, url, title in rows:
                print(f"{fmt_ts(ts)}  {url}" + (f"  [{title}]" if title else ""))
        allrows.extend(rows)

    if not args.per_file:
        allrows.sort(key=lambda r: r[0] or 0, reverse=True)
        print()
        for ts, user, browser, url, title in allrows[:args.n]:
            print(f"{fmt_ts(ts)}  {user:<12} {browser:<9} {url}")

    if not allrows:
        print("No browser history found.", file=sys.stderr)


if __name__ == "__main__":
    main()
