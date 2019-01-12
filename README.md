git clone https://github.com/JacobEberhardt/ZoKrates
cd ZoKrates
docker build -t zokrates .
docker run -ti zokrates /bin/bash
cd ZoKrates/target/release

docker cp circuits/createNote.code zokrates:/home/zokrates/

./zokrates compile -i createNote.code
./zokrates setup
./zokrates export-verifier