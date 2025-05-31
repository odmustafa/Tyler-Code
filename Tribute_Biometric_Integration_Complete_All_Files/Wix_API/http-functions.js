import {ok, badRequest} from 'wix-http-functions';

export function post_login(request) {
  return request.body.text()
    .then(body => {
      const data = JSON.parse(body);
      return fetch("https://your-backend-url/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ fingerprint_scan: data.fingerprint_scan })
      });
    })
    .then(res => res.json())
    .then(json => ok({ body: json }))
    .catch(err => badRequest({ error: err.message }));
}