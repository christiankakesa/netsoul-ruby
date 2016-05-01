# frozen_string_literal: true

require 'mkmf'

have_library('krb5'.freeze, 'krb5_init_context'.freeze)
have_library('gssapi_krb5'.freeze, 'gss_init_sec_context'.freeze)
have_header('string.h'.freeze)
have_header('krb5.h'.freeze)
have_header('gssapi/gssapi.h'.freeze)
have_header('gssapi/gssapi_krb5.h'.freeze)

create_makefile('netsoul_kerberos'.freeze)
