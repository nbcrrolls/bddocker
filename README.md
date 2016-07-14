# Docker container for electrostatic calculations using PDB2PQR/APBS and Brownian dynamics with BrownDye.

This docker image contains a complete software environment for running [BrownDye](http://browndye.ucsd.edu/) simulations. It also includes [PDB2PQR](http://www.poissonboltzmann.org/) and [APBS](http://www.poissonboltzmann.org/).

## Using the container

Pull the docker image:
```
docker pull rokdev/bddocker
```

Start the container in the current directory:
```
docker run --rm -u $USER -ti -v "$PWD":/home/browndye/data -w /home/browndye/data rokdev/bddocker
```

Now the container is running and we can start a BrownDye job (using the Thrombin example):

```
cp -a $BD_PATH/thrombin-example .
cd thrombin-example
sed -i 's/-PE0//g' *
make all
bd_top input.xml
nam_simulation t-m-simulation.xml # this takes about 20min to run
cat results.xml
```
After we are finished we can quit the container:

    exit


###### This project is supported by [NBCR](http://nbcr.ucsd.edu).
