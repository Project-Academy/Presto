#  Presto

`Presto` is a lightweight builder-pattern wrapper on `URLRequest` for configuring and finalising network calls.

Use this when you just want to make a few unique/isolated calls in your application. 
If you're going to make many calls to different endpoints of an API, and those calls will have common features (e.g. authenticated in the same way, always have the same "Content-Type" and "Accept" parameters, or common error-handling processes, then use `Tapioca`.
`Tapioca` protocol-ises the `Request` struct, as well as provides a 'choke-point' for all network calls made to an API, allowing for just in time request modifications (e.g. embedding auth into all outgoing requests, instead of needing to do so at each call site) as well as post-processing the response object (e.g. for handling errors).

 
