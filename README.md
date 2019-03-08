# Docker container for molecular electrostatic calculations using PDB2PQR/APBS and Brownian dynamics with BrownDye.

This docker image contains a complete software environment for running [BrownDye (verion 1 or 2)](http://browndye.ucsd.edu/) simulations. It also includes [PDB2PQR](http://www.poissonboltzmann.org/) and [APBS](http://www.poissonboltzmann.org/).

Please [register](http://eepurl.com/by4eQr) your use of APBS and PDB2PQR.

## Using the container

Pull the docker image:
```
docker pull rokdev/bddocker:v2.0
```

Start the container in the current directory:
```
docker run --rm -ti -u 1000:1000 -v "$PWD":/home/browndye/data -w /home/browndye/data rokdev/bddocker:v2.0
```

Now the container is running and we can start a BrownDye2 job (using the Thrombin example):

```
cp -ai $BD2_PATH/examples/thrombin .
cd thrombin
sed -i 's/-PE0//g' *
make all
```

And if you want to use BrownDye version 1:

```
export PATH=$BD1_PATH/bin:$PATH
cp -a $BD1_PATH/thrombin-example .
cd thrombin-example
sed -i 's/-PE0//g' *
make all
bd_top input.xml
nam_simulation t-m-simulation.xml # this takes about 20min to run
cat results.xml
```

After we are finished we can quit the container:
```
exit
```

###### This project is supported by [NBCR](http://nbcr.ucsd.edu).
