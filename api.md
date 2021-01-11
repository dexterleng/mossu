# API Documentation

Refer to the Falcon Server [source code](https://github.com/dexterleng/falcon-server) as a example of a system integrating with mossu.

All APIs with the exception of `POST /auth/signin` require the user to be authenticated.

The JWT token can be retrieved from `POST /auth/signin/` and is to be provided through the `Authorization` header:

```
Authorization: Bearer <JWT token>
```

Checks are designed to be immutable once they are started (`check.status != created`). The submissions and base submission associated with the check can no longer change. Create a new check with the new submissions/base submission instead.

## `POST /auth/signin`

Retrieve a JWT Token. The token will expire in 24h.

Request Body:

```
auth: {
  email: string,
  password: string,
}
```

Response Code: `201 Created`

Response Body:

```
{
    "jwt": string
}
```

## `GET /checks/`

Get all checks created by the authenticated user.

Response Code: `200 OK`

Response Body:

```
[
    {
        "id": int,
        "name": string
        "status": "created" | "queued" | "active" | "completed" | "failed",
        "created_at": string,
        "updated_at": string,
        "user_id": int
    },
]
```

## `GET /checks/:id`

Get a check created by the authenticated user.

Response Code: `200 OK`

Response Body:

```
{
    "id": int,
    "name": string
    "status": "created" | "queued" | "active" | "completed" | "failed",
    "created_at": string,
    "updated_at": string,
    "user_id": int
}
```

## `POST /checks/`

Create a check.

Request Body:

```
{
	"name": string
}
```

Response Code: `200 OK`

Response Body:

```
{
    "id": int,
    "name": string
    "status": "created" | "queued" | "active" | "completed" | "failed",
    "created_at": string,
    "updated_at": string,
    "user_id": int
}
```

## `POST /checks/:id/start`

Start a check. A check job will be enqueued. The job status is reflected in `check.status`.

To start a check, the check must:

1. have a `status` of `created`
2. `submissions.count >= 2`

Response Code: `202 Accepted`

## `GET /checks/:id/report/`

Download the unanonymized report zip.

The report should only be available when `check.status` is `completed`. Expect a `404 Not Found` otherwise.

## `PUT /checks/:id/base_submission`

Upload the base submission zip. It will be unzipped and the Javascript files will be sent to MOSS as base files. `node_modules/*` will be ignored.

`check.status` must be `created`.

Refer to the MOSS documentation on the base file:
```
# The -b option names a "base file".  Moss normally reports all code
# that matches in pairs of files.  When a base file is supplied,
# program code that also appears in the base file is not counted in matches.
# A typical base file will include, for example, the instructor-supplied 
# code for an assignment.  Multiple -b options are allowed.  You should 
# use a base file if it is convenient; base files improve results, but 
# are not usually necessary for obtaining useful information. 
#
# IMPORTANT: Unlike previous versions of moss, the -b option *always*
# takes a single filename, even if the -d option is also used.
```

Form Data:

```
base_submission: <zip file>
```

## `POST /submissions/`

Create a submission associated with a check. During the check job, the JS files in the zip will be anonymized and uploaded to MOSS. `node_modules/*` will be ignored. 

`check.status` must be `created`.

Form Data:

```
submission[check_id]: int
submission[zip_file] = <zip file>
```