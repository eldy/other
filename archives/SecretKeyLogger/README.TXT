
            Hooker, the intelligent trojan keylogger
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                          (version 2.4)




    Disclaimer
    ~~~~~~~~~~
      This  program  was  created  in  educational purposes only.
     Authors do not will be  liable for data loss,  damages, loss
     of  profits  for  any other  kind  of loss  while  using  or
     misusing this program.  No  person or  company  may charge a
     fee for  the distribution of Hooker.  Authors do not will be
     liable for any kind of illegal using of this program. Hooker
     may be distributed freely without any charge for it. Authors
     do not mind  about the disassembling of any part of code. If
     you do not agree with this terms, stop using this program. 

    What is Hooker?
    ~~~~~~~~~~~~~~~
    Hooker is the simple mailing trojan. Here is the list of it's
features:

        - keylog function (fairly simple, not so extended like in
        HookDump)
        - You can define any option you can imagine  -  there are
        tons of them
        - Hooker can look for RAS-connections
        - Hooker can download files from any location in internet
        and start them absolutely  invisible from user  - you can
        use hooker as intruding  module for  starting  the bigger
        trojans like NetBus or BO
        - Works under any Win32 platform (Win95/98/NT)
        - Well-commented sources are available for free - you can
        build your very own version of hooker ;)

     Trojan  part is  written on  MS  Visual C++ 5.0.  MFC or any
another nonstandard libraries wasn't used.  Therefore, Hooker can
be executed on any  Win32 platform  with minimum set of DLLs. May
be,  Hooker can be compiled  under Borland C or even  Watcom, but
we have  not tested it.  I think  that Hooker  can be viewed as a
classical  sample of trojan.  And may be,  someone can build smth
really good based on Hooker. And  may be, he (or  she)  will even
credit us... :)


     Installation in system
     ~~~~~~~~~~~~~~~~~~~~~~
     During the first run Hooker moves it's body into directory
which is predefined in the configuration. You should keep in mind
following things, when you will choose the place in registry from
which Hooker will run:

     HKEY_LOCAL_MACHINE - Hooker will start with any user
     HKEY_CURRENT_USER  - Hooker will start only with current user

     \Software\Microsoft\Windows\CurrentVersoin\, and variants:

     Run             if there  is  only name  of  file  w/o path,
                     Hooker  must be in  the directory,  which is
                     defined in  the %PATH% environment variable.
                     Remember,  that   system  directory  is  not
                     defined in %PATH% by default.

     RunServices     file must  be placed in the system directory
                     (if there is only  name without path). Works
                     only under Win95/98.

     RunOnce         used to run file only once. During the boot,
                     OS  will  start  file,  then  wait  for it's
                     termination and then kill it from RunOnce.

     RunServicesOnce like a RunOnce, but for system directory.
                     Does not work under WinNT.

     Hooker can  be called from RunOnce and  RunServicesOnce, and
it  will  not  pause  the boot  process,  because it will restart
imediatelly with the Restart_ID key, where ID is the ident number
(DWORD, computed from the date and time of configuration). Hooker
will not be started only once, because it will rewrite it's sting
in RunOnce (RunServicesOnce) in a short period of time.


     Keylogging
     ~~~~~~~~~~
     Keylogging  feature is  very  simple under Win32.  It can be
done using the system hook. All you need  is to redefine CallBack
function  used for keypresses to yours, which must be situated in
DLL.  In Hooker CallBack  function writes  pressed keys in little
buffer in the segment of dynamic data for this DLL. By calling of
the appropriate  DLL-functions you  can free  this buffer or read
information  from it.  We recommend  to give  different  names to
keylogging dll for every configuration you create. There are some
options for keylog which you can choose depending of the aims you
follow and preferred size of log:

     - Hooker can log  keypresses in the  every window or only in
     windows  which have predefined substring in it's titles (for
     example, "login", "passw", "term" etc).
     - Hooker can log all  keys including  SHIFT, ALT, TAB, CTRL,
     Caps Lock etc or log only text-keys (chars etc).
     - sometimes you want to spy for pc  -  then set "Log windows
     where nothing  was pressed" feature on.  Believe us, you can
     get so many information just in looking the titles and links
     your "victim" surfs.

     If you do not  want keylog  feature,  then  just  delete all
substring to search and set "Full keylog" option off.



     Detecting of modem-connections.
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     How program can  say, are  you connected to internet or not?
There is no solution which can cover  all the situations. If user
connects to inet using  the Dial-Up Networking, then he or she is
using RAS-functions - it's the mostly used case, and in this case
RASAPI32.DLL is used. But sometimes people connects to inet via
LAN, and RAS is not used. Therefore, you must wisely set option
"RAS" - set it to on if RAS is used, and to off if not.
     If connection is successfully established, Hooker logs time,
phone number, IP of user and IP of server.


     Web-files downloading and executing
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     Number of  programs for  remote administering  if countless.
BackOrifice, NetBus,  DeepThroat, WinCrash...  Tons...  And their
weight (in kbs) is usually tons. :)  Hooker's size is only 20 kb,
but it  is  not so  complex like  BO.  And here  goes one  of the
innovating options:  hooker can  download and  execute files from
web using http protocol.  Hooker downloads  file from  web in the
system directory of  windows and then executes it.  If connection
will be crashed during  the download, Hooker will redownload file
as far as possible. Check for a update performs every 30 minutes.
If you want to download  file from a  nonstandard http port write
addres like this: www.myhost.com/file.exe:8000


     Thanks
     ~~~~~~
     Thanks to all who tested Hooker, gave ideas and simply wrote
all that they think about us. :)
Eprst  happy99@mail.ru,     Harmer    harmer@mail.ru,        Alex
tanatos@mail.ru,  Plan paln@mail.ru,  Павел praver@mail.ru,  Dima
dmetry@usa.net,     Androyd   androyd@chat.ru,      Dark     Monk
darkmonk@mail.ru
and to all I forgot...




Write us:  hooker@mail.ru  or  shade@beer.com



                   ACrazzi & Shade, 24.7.1999

P.S. [from Shade] Sorry for my terrible english... If you want to
fix all my mistakes, write to shade@beer.com.