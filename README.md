### Note: I am practicing Readme Driven Development here so don't expect all features to work until 1.0

# Env.rb
Managing your ENVironment

## Purpose
Many modern web applications consume and post to resources that reside at other urls, often requiring
more authentication tokens than a database password.  These passwords need to be stored in some
location.  A common, secure location that exists outside of the source directory  is in the 
application's runtime environment.  

However, consuming a resource at a url can take up to three different variables to represent
the location, username, and password.  If your app is consuming many endpoints the sheer
number of variables can become overwhelming.  Remember, the average short-term memory holds
about 7 items.  Certain production applications can have upwards of 50 to 100 ENV vars.

Env.rb allows you to declare environment variables like dependencies and configure multiple 
environments with a simple ruby DSL.  It provides tools for cleaning up existing apps, exporting
your Envfile to a shell-compatible format, and executing scripts within your environments.

## Examples

### Explictly declaring your environment

#### Envfile
    import 'TEST'
    export 'TEXT', '15'

#### Use

    require 'env'

    ENV['HELLO_WORLD']            # => nil
    ENV['TEST'] = 5
    Env.load!                     # look for Envfile

    ENV['HELLO_WORLD']
    # => EnvironmentError: HELLO_WORLD is not a declared dependency

    ENV['TEST']  # => 5 
    ENV['TEXT']  # => 15 
    
### Groups
#### Envfile

    export "PROVIDER_PASSWORD", '1234', :group => :development

    group :development do
      export "SERVICE_URL", 'http://username:password@www.service.com/path"
    end

    group :test do
      export "SERVICE_URL", 'http://username:password@example.com/"
    end

#### Use
    Env.load!                     
     -same as-
    Env.load! :default

    Env.load! :default, :test
    ENV['SERVICE_URL']    # => 'http://username:password@example.com/"

    Env.load! :development
    ENV['SERVICE_URL']    # => 'http://username:password@www.service.com/path"

### Mutability

#### Envfile
    export 'TEXT', '15', :mutable => false
    export 'TEXT', '15', :immutable => false

#### Use

    ENV['TEST']  # => 15 

    ENV['TEST'] = 'overriding' 
    # => EnvironmentError: variable TEST cannot be changed

## Built-in support for URIs

### Envfile
    export "SERVICE",     'http://username:password@example.com/"

### Use
    ENV['SERVICE']             #=> 'http://username:password@example.com/"
    ENV['SERVICE'].base_uri    #=> 'http://example.com/"
    ENV['SERVICE'].url         #=> 'http://example.com/"
    ENV['SERVICE'].user        #=> 'username'
    ENV['SERVICE'].password    #=> 'password'
    ENV['SERVICE'].host        #=> 'example.com'
    ENV['SERVICE'].scheme      #=> 'http'

