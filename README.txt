Loml

Setup
--------------------
Before you run our project, there are several dependencies you must install.
The below commands should set up the dependencies necessary for this project.

opam update
opam upgrade
opam install cohttp=0.99.0 lwt js_of_ocaml
opam install cohttp-lwt-unix=0.99.0 cohttp-async=0.99.0 cohttp-lwt-jsoo=0.99.0 cohttp-lwt=0.99.0 cohttp-lwt-unix cohttp-top=0.99.0
opam depext conf-mysql
opam install mysql
-------------------
Running
-------------------
After running the above commands, the environment should be set up and you can test this by switching to the directory with the
src files and running make compile. If this is successful then the environment is set up correctly.


If you want to play and run the program you must first run the commands shown below.

make clean
make play

**NOTE: The server must be running in order for the program to run without any errors. 
For our purposes, the server is already running at http://en-cs-3110project2.coecis.cornell.edu:8000/. It is accessible anywhere
at Cornell or by using the Cornell VPN. You will be fully able to utilize the client side architecture without configuring
anything else. You may take a look at our server code in our source. Additionally, we have given our graders access to our
coecis server. You can ssh into it and access the database using

mysql test -u root -padmin123

To ensure that the server is running, run
ps aux | grep "server.byte"

The output should be something like:

ab2466   22864  0.0  0.0   4508   784 ?        S    Dec06   0:00 /bin/sh -c make && ./server.byte
ab2466   22866  0.0  0.2  77020 11560 ?        Sl   Dec06   0:00 /home/ab2466/.opam/4.05.0/bin/ocamlrun ./server.byte

But if you really want to spin up your own server, here's what you can do:

Clone the repo and run make server. You will also need to:
Replace the http://en-cs-3110project2.coecis.cornell.edu in backend_lib.base_url with your own IP address.
NOTE: requests to localhost:8000/ are not supported by cohttp; you have to use your actual ip address. To configure the database, run
the following
To configure the database,run the following commands in the MySQL command line:

CREATE DATABASE test;
If database test already exists then ignore previous command. 

USE test;

CREATE TABLE students (netid VARCHAR(7), name VARCHAR(50), year VARCHAR(10), schedule VARCHAR(1500), courses VARCHAR(1500), hours INT, profile VARCHAR(500), location VARCHAR(40));

CREATE TABLE matches (stu1 VARCHAR(12), stu2 VARCHAR(12));

CREATE TABLE credentials (netid VARCHAR(7), password VARCHAR(50));

CREATE TABLE periods (u VARCHAR(50), s VARCHAR(50), m VARCHAR(50));

CREATE TABLE swipes (netid VARCHAR(7), swipes VARCHAR(500));


and replace the database connect information in db.ml with your local configuration.
