//
// Project:: Terraform Module - static-site
//
// Copyright 2021, Route 1337, LLC, All Rights Reserved.
//
// Maintainers:
// - Matthew Ahrenstein: matthew@route1337.com
//
// See LICENSE
//

'use strict';

exports.handler = async (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    headers['Strict-Transport-Security'] = [{
        key: 'Strict-Transport-Security',
        value: 'max-age=63072000; includeSubDomains; preload',
    }];

    headers['X-XSS-Protection'] = [{
        key: 'X-XSS-Protection',
        value: '1; mode=block',
    }];

    headers['X-Content-Type-Options'] = [{
        key: 'X-Content-Type-Options',
        value: 'nosniff',
    }];

    headers['X-Frame-Options'] = [{
        key: 'X-Frame-Options',
        value: 'SAMEORIGIN',
    }];

    headers['Referrer-Policy'] = [{ key: 'Referrer-Policy', value: 'no-referrer-when-downgrade' }];

    headers['Content-Security-Policy'] = [{
        key: 'Content-Security-Policy',
        value: 'upgrade-insecure-requests;',
    }];

    // Craft the Feature Policy params based on your needs.
    // The settings below are very restrictive and might produce undesiderable results
    headers['Feature-Policy'] = [{
        key: 'Feature-Policy',
        value: 'geolocation self; fullscreen self; animations self; camera self;'
    }];

    // The Expect-CT header is still experimental. Uncomment the code only if you have a report-uri
    // You may refer to report-uri.com to setup an account and set your own URI
    // headers['Expect-CT'] = [{
    //     key: 'Expect-CT',
    //     value: 'max-age=86400, enforce, report-uri="https://{{ your_subdomain }}report-uri.com/r/d/ct/enforce'",
    // }];
    callback(null, response);
};
