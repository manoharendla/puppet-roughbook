# puppet-roughbook

## Setting up Puppet development environment

### Installing Puppet Development kit:

Download and install the PDK kit using the link https://puppet.com/download-puppet-development-kit 

### PDK commands:

1. `pdk new module testmod` : Will generate a module witha folder structure which also conatins a metadata.json file 
2. `pdk validate metadata` : will check for any syntax errors in metadata.json file. 
3. `pdk validate --list` : list all default validators . This has three validators
    *ruby*
    *Puppet*
    *metdata*
4. `pdk validate` : To validate files of all types
5. `pdk new class testmod`: Creates a new puppet class, as the class name is same as module name,pdk is smart enough to create it as       init.pp file and also it creates a testmod_spec.rb in spec folder
6. `pdk validate --parallel`: To run the validation simultaneously for all types.
7. `pdk test unit`: Runs unit test cases against the test file generated . 
8. `pdk new task restart` : Creates a new task named restart a shell script file and a json file with name of the task 


### Adapting existing modules to PDK:

1. Start with a fresh clone of your module
2. Check your Gemfile compatibilty and make appropriate change. Compare the gemfile in your repository with the gen file genraetd as part of PDK
3. Copy the .rubocopy.yml' file from the pdk-module-tenplate into your module root (https://github.com/puppetlabs/pdk-module-template)
4. Run `pdk validate` so that pdk can resolve and install missing gem dependencies into its cache
5. `pdk validate ruby -a`, it auto coorrects the ruby warnings.


### PDK on CI 
1. `pdk validate --format junit`

### Validate ERB templates
`erb -x -T '-' template.erb`


### Puppet class example

*Define a class:*

```ruby
class mysql (
    $root_password => 'default_password',
    $port          => 3304
) {
    package { 'mysql-server':
        ensure => present,
    }
    service { 'mysql':
        ensure => running,
        enable => true,
    }
}

```

*Declare/Instantiate a defined class:*
*Two ways:*
1. Using include keyword but without params `include mysql`
2. Using class declaration with parameters, but can be instantiated only once, otherwise puppet will through a duplicate resource error
```ruby
class { 'mysql':
    root_password => 'temp_password',
    port          => '3306',
    }

```

*Defined resource types or defined types:*
Similar to parameterized classes defined but used multiple times(with different titles)

*Defining defined types*
```ruby
define example(
    $key1 => value1,
    $key2 => value2,
){
  package { 'somepackage':
      ensure => present,
 }
 file { 'var_$name':
      path => '/var/lib/jenkins',
      ensure => 'present',      
 }
 }
```

*Instantiating a defined type*

```ruby
example { 'File1':
    key1 => value2,
}

example { 'File2':
    key1 => value3,
}

```
