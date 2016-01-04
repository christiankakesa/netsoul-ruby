/*
** This file is part of RubySoul project.
**
** Test for the kerberos authentication.
**
** @author Christian KAKESA <christian.kakesa@gmail.com>
*/

#include <ruby.h>

#include "kerberos.h"

VALUE cNetsoulKerberos;

static VALUE k_init(VALUE self)
{
	rb_define_attr(cNetsoulKerberos, "login",        1, 1);
	rb_define_attr(cNetsoulKerberos, "password",     1, 1);
	rb_define_attr(cNetsoulKerberos, "token",        1, 0);
	rb_define_attr(cNetsoulKerberos, "token_base64", 1, 0);
	return self;
}

static VALUE k_build_token(VALUE self, VALUE login, VALUE password)
{
	k_data_t	  *data;
	unsigned char *token_base64;
	unsigned char *token;
	size_t		  elen;

	data = calloc(1, sizeof (k_data_t));
	data->login = (char*)login;
	data->unix_pass = (char*)password;
	data->itoken = GSS_C_NO_BUFFER;
	if (check_tokens(data) != 1) {
	    free(data);
	    return Qfalse;
	}

	token = (unsigned char*)strdup(data->otoken.value);
	token_base64 = base64_encode((const unsigned char*)data->otoken.value, data->otoken.length, &elen);
	rb_iv_set(self, "@login", login);
	rb_iv_set(self, "@password", password);
	rb_iv_set(self, "@token", rb_str_new2((const char*)token));
	rb_iv_set(self, "@token_base64", rb_str_new2((const char*)token_base64));
	free(token);
	free(token_base64);
	free(data);
	return Qtrue;
}

void Init_netsoul_kerberos()
{
	cNetsoulKerberos = rb_define_class("NetsoulKerberos", rb_cObject);
	rb_define_method(cNetsoulKerberos, "initialize", k_init, 0);
	rb_define_method(cNetsoulKerberos, "build_token", k_build_token, 2);
}
