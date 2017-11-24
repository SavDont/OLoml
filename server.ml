open HttpServer
open Api

let _ = 
  HttpServer.add_route (`GET, "/student") Api.student_get;
  HttpServer.add_route (`POST, "/student") Api.student_post;
  HttpServer.add_route (`GET, "/admin") Api.admin_get;
  HttpServer.add_route (`POST, "/admin") Api.admin_post;
  HttpServer.add_route (`DELETE, "/admin") Api.admin_delete;
  HttpServer.run ~port:8000 ()
