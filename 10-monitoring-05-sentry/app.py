#!/usr/bin/env python

import requests
import sentry_sdk
sentry_sdk.init(
    dsn="https://45e17b1bec684bf3bf1a39e8e5d10f75@o4505487895560192.ingest.sentry.io/4505487900672000",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
)

url='http://dimi.link/netology'

try:
    r = requests.get(url,timeout=3)
    r.raise_for_status()
except requests.exceptions.RequestException as err:
    print ("OOps: Something Else",err)
    sentry_sdk.capture_exception(err)
except requests.exceptions.HTTPError as errh:
    print ("Http Error:",errh)
    sentry_sdk.capture_exception(errh)
except requests.exceptions.ConnectionError as errc:
    print ("Error Connecting:",errc)
    sentry_sdk.capture_exception(errc)
except requests.exceptions.Timeout as errt:
    print ("Timeout Error:",errt)
    sentry_sdk.capture_exception(errt)