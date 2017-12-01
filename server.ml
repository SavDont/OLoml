open HttpServer
open Api

let _ = 
  HttpServer.add_route (`POST, "/test/") Api.test_post;
  HttpServer.add_route (`GET, "/test/") Api.test_get;
  HttpServer.add_route (`POST, "/credentials/") Api.credentials_post;
  HttpServer.add_route (`GET, "/period/") Api.period_get;
  HttpServer.add_route (`POST, "/period/") Api.period_post;
  HttpServer.add_route (`GET, "/swipes/") Api.swipes_get;
  HttpServer.add_route (`POST, "/swipes/") Api.swipes_post;
  HttpServer.add_route (`POST, "/matches/") Api.matches_post;
  HttpServer.add_route (`GET, "/student/") Api.student_get;
  HttpServer.add_route (`POST, "/student/") Api.student_post;
  HttpServer.add_route (`GET, "/admin/") Api.admin_get;
  HttpServer.add_route (`POST, "/admin/") Api.admin_post;
  HttpServer.add_route (`DELETE, "/admin/") Api.admin_delete;
  HttpServer.run ~port:8000 ()
