# Docker container for molecular electrostatic calculations using PDB2PQR/APBS and Brownian dynamics with BrownDye.

This docker image contains a complete software environment for running [BrownDye (version 2)](https://browndye.ucsd.edu/) simulations. It also includes [PDB2PQR](https://www.poissonboltzmann.org/) and [APBS](https://www.poissonboltzmann.org/).

Please [register](http://eepurl.com/by4eQr) your use of APBS and PDB2PQR and at https://browndye.ucsd.edu/ for use of BrownDye.

## Using the container

Pull the docker image:
```
docker pull rokdev/bddocker:latest
```

Start the container in the current directory:
```
docker run --rm -ti -u 1000:1000 -v "$PWD":/home/browndye/data \
 -w /home/browndye/data rokdev/bddocker:latest
```

Now the container is running and we can start a BrownDye2 simulation (using the Thrombin example):

```
cp -ai $BD2_PATH/examples/thrombin .
cd thrombin
sed -i 's/<n_trajectories> 1000 /<n_trajectories> 100 /' input.xml.bak
make all
bd_top input.xml
nam_simulation thrombin_tmodulin_simulation.xml # takes about 4 min to run
cat results.xml
```

After we are finished we can quit the container:

```
exit
```

Latest docker images builds can be seen on [Docker Hub](https://cloud.docker.com/repository/docker/rokdev/bddocker).

###### This project is supported by a grant from the [National Institutes of Health](https://www.nih.gov).
