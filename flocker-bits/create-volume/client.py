"""
A collection of utilities for using the flocker REST API.
"""

from treq.client import HTTPClient

from twisted.internet import reactor, ssl, defer
from twisted.python.usage import UsageError
from twisted.python.filepath import FilePath
from twisted.web.client import Agent

import os
import sys
import yaml
import treq
import copy


def get_client(reactor=reactor, certificates_path=FilePath("/etc/flocker"),
        user_certificate_filename="user.crt", user_key_filename="user.key",
        cluster_certificate_filename="cluster.crt"):
    """
    Create a ``treq``-API object that implements the REST API TLS
    authentication.

    That is, validating the control service as well as presenting a
    certificate to the control service for authentication.

    :return: ``treq`` compatible object.
    """
    user_crt = certificates_path.child(user_certificate_filename)
    user_key = certificates_path.child(user_key_filename)
    cluster_crt = certificates_path.child(cluster_certificate_filename)

    if (user_crt.exists() and user_key.exists() and cluster_crt.exists()
            is not None):
        # we are installed on a flocker node with a certificate, try to reuse
        # it for auth against the control service
        cert_data = cluster_crt.getContent()
        auth_data = user_crt.getContent() + user_key.getContent()

        authority = ssl.Certificate.loadPEM(cert_data)
        client_certificate = ssl.PrivateCertificate.loadPEM(auth_data)

        class ContextFactory(object):
            def getContext(self, hostname, port):
                context = client_certificate.options(authority).getContext()
                return context

        return HTTPClient(Agent(reactor, contextFactory=ContextFactory()))
    else:
        raise Exception("Not enough information to construct TLS context: "
                "user_crt: %s, cluster_crt: %s, user_key: %s" % (
                    user_crt, cluster_crt, user_key))
