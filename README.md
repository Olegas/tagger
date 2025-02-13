# Rhoban patches tagger

## Introduction

The tagger is a tool allowing you to upload several patches (small images) and tag them under some categories in order to train neural networks

![imgs/tagger.png](imgs/tagger.png)

## Installing

### Using Docker

You can start tagger by using `docker-compose.yml`. Just run:

    docker-compose up

It will:

 1. Start Apache2+PHP7+tagger
 1. Start MariaDB (drop-in replacement for MySQL)
 1. Create DB schema
 1. Create user `admin` with password `admin` and `ROLE_ADMIN` role

One can use `console` commands mentioned below if connected to container using regular shell (typically container name is `tagger-tagger-1`).
Working directory for application is `/var/www`. App configuration file can be found at `/var/www/.env`.

### Cloning and getting dependencies

The current version is based on the Symfony framework and require a MySQL database.

First, clone this repository and run the [composer installation](https://getcomposer.org/):

    git clone https://github.com/Rhoban/tagger.git
    cd tagger
    composer install

*Note: composer can be obtained on [getcomposer.org](https://getcomposer.org/) or via `apt install composer` on a debian installation*

### Configuring the database

You then need to configure the app, edit the `.env` file and change the `DATABASE_URL` so that it matches your database configuration.

You can now create the database schema using:

    ./bin/console doctrine:schema:create

### Getting the first administrator

You can now deploy and run the application (reaching the Symfony `public/` directory from your web server supporting PHP), and register your first account.

To promote the first admin, you can use the Friends Of Symfony command line:

    ./bin/console fos:user:promote

And then enter the username, and `ROLE_ADMIN` like this:

    Please choose a username: gregwar
    Please choose a role: ROLE_ADMIN

You might need to logout and login again to have this taking effect.

## Using

### Managing categories

First, you need to create `categories`, log in on any admin account and click on the category menu on the top.

The categories are basically things that you want to tag. In our robots at the RoboCup we tag for instance balls and goal posts.

### Sessions and sequences

Next, you need to upload log sessions that you want to tag. A session can be any way of separating your batches of patches. A session contain several sequences that are typically shot sequentially, and can be used to know where each patch come from more accurately.

For example:

* Sesion 1: "Training field at our lab"
    * Sequence 1: "Robot 1 at 10:01"
    * Sequence 2: "Robot 1 at 10:09"
    * Sequence 3: "Robot 2 at 10:12"
* Session 2: "Field A at RoboCup 2017"
    * Sequence 1: "Robot 1 at 12:31"
    * Sequence 2: "Robot 2 at 12:45"

Thus, we can for instance disable the session that was using for training at our lab when we want only to tag the patches at the competition. Moreover, we can also remove sequences from the Robot 1 if we note that there was a big mistake in the patch extraction.

To create sequence, you need to upload patches using the upload process

### Uploading

The archive can have any structure, as long as it ends with directories with categories names, like:

```
robot1/
    17h59/
        goal/
            1.png
            2.png
            3.png
        ball/
            1.png
            2.png
            3.png
    18h05
        goal/
            1.png
            2.png
            3.png
```

Will result in having two sequences, one named `robot1_17h59` containing patches for `goal<` category and patches for `ball` category, and one named `>robot1_18h05` containing patches for `goal` category.

*Note: if you want to have the progress bar to work, you have to enable the `session.upload_progress.enabled` in the PHP configuration*

### Tagging

When tagging, a grid of images is presented to you:

![imgs/grid.png](imgs/grid.png)

Images you don't click will be registered as negative for the current category. With one click, you mark the images as positive for the class. With two click, you mark it as unknown which means that you don't want it to be used for training because it's ambiguous (for instance, if you have images that will not appear in real situations):

![imgs/grid_tagged.png](imgs/grid_tagged.png)

You can then click OK and tag the next grid.

*Note: you can choose the size of the images and the grid in "My settings", this can be handful to adapt the size of the grid to your screen or the device you are currently using*

### Consensus

To have images actually accepted in one category, you need it to have consensus, which mean that:

* At least `CONSENSUS_MIN_USERS` tagged it, default is 2
* There is one class (yes, no or unknown) accepted by a ratio higher than `CONSENSUS_THRESHOLD`, default is 0.6 (60%)

You can change these values by putting it in your `.env` file, for example:

    CONSENSUS_MIN_USERS=1
    CONSENSUS_THRESHOLD=0.6

Will make that one user alone will be able to trigger a consensus

*Note: if you update the values of the consensus settings, you might also want to run `./bin/console app:consensus` to update the statistics*

### Training

This feature is optional, add `TRAINING=1` in the .env file to enable it.

When fresh users registers, they are marked as not trained, meaning that they are not allowed to tag unless they completed a training session.

To achieve this:

* Tick the "training" box when editing sessions that you want to include in the process of training new users
* Tag the images from these sessions
* You can, if you want, disable these sessions so they are not in the standard tag process (and let the training flag)

*Notes: admin doesn't need to be trained, it is also possible to manually mark someone as trained in the administration of users.*

## LICENSE

This is under MIT license. Please refer to the `LICENSE` file for more information
