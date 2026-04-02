# shared

Cross-service contracts. Every service should import schemas from here
rather than duplicating them.

| Directory  | Contents                                |
|------------|-----------------------------------------|
| `proto/`   | Protobuf definitions (gRPC, future)     |
| `openapi/` | OpenAPI 3 specs for each service        |
| `events/`  | Async event / message schemas           |
