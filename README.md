# OLoml

OLoml (O Love of my Life), is a Tinder style app for people searching for partners in their classes. 

### Contributors:
Aayush Beri, Samantha Dimmer, Savarn Dontamsetti, Myra Gupta

### Setup

Before you run our project, there are several dependencies you must install.

 Firstly, you need to install OCaml - follow the instructions [here](http://www.cs.cornell.edu/courses/cs3110/2017fa/install.html)
 
Once OCaml is installed, the below commands should set up the dependencies necessary for this project.

    opam update
    opam upgrade
    opam install cohttp=0.99.0 lwt js_of_ocaml
    opam install cohttp-lwt-unix=0.99.0 cohttp-async=0.99.0 cohttp-lwt-jsoo=0.99.0 cohttp-lwt=0.99.0 cohttp-lwt-unix cohttp-top=0.99.0
    sudo apt-get update #NOTE:Only for Ubuntu machines
    opam depext conf-mysql
    opam install mysql

After running the above commands, run `make compile` to ensure the dependencies are satisfied. If no errors occur, the environment is set up corrrectly.

### Networking
For the purpose of the project, we had a dedicated server. To spin up a local server on port 8000 here's what you can do:

Clone the repo and run `make server`. You will also need to:
Replace the http://en-cs-3110project2.coecis.cornell.edu in `backend_lib.base_url` with your own IP address.
NOTE: requests to localhost:8000/ are not supported by [cohttp](https://github.com/mirage/ocaml-cohttp); you have to use your actual ip address. 

To change the port, you can modify line 18 in `server.ml` 

To configure the database, run the following commands in the MySQL command line:

    CREATE DATABASE test;
    If database test already exists then ignore previous command. 
    
    USE test;
    
    CREATE TABLE students (netid VARCHAR(7), name VARCHAR(50), year VARCHAR(10), schedule VARCHAR(1500), courses VARCHAR(1500), hours INT, profile VARCHAR(500), location VARCHAR(40));
    
    CREATE TABLE matches (stu1 VARCHAR(12), stu2 VARCHAR(12));
    
    CREATE TABLE credentials (netid VARCHAR(7), password VARCHAR(50));
    
    CREATE TABLE periods (u VARCHAR(50), s VARCHAR(50), m VARCHAR(50));
    
    CREATE TABLE swipes (netid VARCHAR(7), swipes VARCHAR(65535));


and replace the database connect information in db.ml with your local configuration.

### Running
Run

    make clean
    make play

### Notes
OLoml was developed as the final project for [CS3110](http://www.cs.cornell.edu/courses/cs3110/2017fa/) - Data Structures and Functional Programming. As such, it is far from perfect. Suggestions and contributions welcome.
