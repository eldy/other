#!/usr/bin/perl
# index.cgi
# Redirect to another URL

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();
&redirect($config{'link'});

