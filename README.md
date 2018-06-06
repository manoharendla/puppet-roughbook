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

### Hiera example:
*Why hiera is used ?*
Hiera is a key value lookup tool that will help in separating the data from code.

*Hiera installation directory and configuration file*
By default hiera.yaml file is located at /etc/puppet/ but we can use a custom path by using a parameter named hiera_config  parameter inside puppet.conf file. 

*How does hiera.yaml look like:*
```yaml
:hierarchy:
    -"%{::osfamily}"
    - common
:backends:
    - yaml
:yaml:
    :datadir: '/etc/puppet/hieradata/'
```

*hierarchy* acts as an datasource for hiera lookup. It can refer static or dynamic datasource (file with yaml extension in datadir). Dynamic data source can be defined using %{::osfamily}
*backends*  Search through all yaml files
*datadir* Where the yaml configuration files are located

*The steps to follow:*
1. Create yaml files for node specific 
   ex: Redhat.yaml, Debian.yaml
2. Define the key value pair in Redhat.yaml file and Debian.yaml file
   ex: cat Redhat.yaml
     sshservicename=sshd
    ex : cat Debian.yaml
       sshservicename=ssh
3. Now from the puppet manifest, the values can be read using  $servicename= hiera('sshservicename')
4. When a Redhat puppet agent sends facts to the master server, it would get the lookup operation will get the details from Redhat.yaml file.


We can also declare the class level variables 
*cat common.yaml* (usally define the dfault value)

classname::keyname: 'value'

ex: 
ntp::ntp_regional_server: (array of strings)
  - 'uk.pool.ntp.org'
  - 'us.pool.ntp.org'
ntp::monitor: true (boolean)

ntp::ntp_local_server: '192.168.0.2' (string)


### Puppet best practices for Writing Manifests
 ex: 
```ruby
  file { '/etc/sshd/ssh.conf':
    ensure => present,
  }
``` 
1. Must use two space soft tabs :   *line no.2 in the below manifest is provided with two spaces* 
2. No space between title and colon 
3. No trailing white spaces
4. End with a new line

### Best practices for hashes and arrays.
ex:
```ruby
service { 'foo':
  require => [
    File['foo1'],
    File['foo2'],
  ],
}

$my_hash = { 
  key1 => 'value1',
  key2 => 'value2',
}

```

1. Each element on new line.

### Quoting 

*Good*
```ruby
"/etc/${facts['operatingsystem']}"
"/etc/${file}.conf"
```

1. Donot use single quote if a string contains a variable

### Comments
Comments should always use the hash(#) key.

### Resource names or titles
All resource names should be quoted

```ruby

package { 'openssh':
  ensure => present,
  before => Service['openssh'],
}
```
### Notify:

```ruby
notify { 'warning': message => 'This is a warning message' } 
```

### Attribute order

Ensure attribute should be defined first, so that the user can quickly identify if the resource if being created or deleted.
Splat(* ) attribute should be defined last.

```ruby
${file_ownership} = {
  'owner' => 'root',
  'group' => 'wheel',
  'mode'  => '0644',
 }
 
 file { '/etc/password':
   ensure => present,
   *      => ${file_ownership},
 }
 ```
### Resource Arrangement
*With in a group resources should be grouped by logical relationship with each other rather than with resource type*

```ruby
file { '/var/lib/':
  ensure => directory,
}

file { '/var/lib/log.txt':
  ensure => file,
}

file { '/var/softwares':
  ensure => directory,
}

file { '/var/softwares/vm.txt':
   ensure => file,
}
```

### Creating multiple directories using an array:

```ruby
class app {
  $dir = ['/var/lib/logs','/var/lib/mysql','/var/lib/psql']
  
  file { ${dir}:
    ensure => directory,
    mode   => 0644,
  }
}


```

### Use of default keyword for setting default attributes:

```ruby
class defaultexample {
  file {
    default:
      ensure => file,
      owner  => 'root',
      group  => 'wheel',
      mode   => '0644',
    ;
    '/var/lib/mysql/mysql.txt':
    ;
    '/var/log/tmp.txt':
    ;
    '/var/log/ab.txt':
      mode => '0666',
    ;
    '/var/tmp/tmp2.txt':
      owner => 'user1',
    ; 
  }
}

```

### Write a puppet manifest that will create some files with default attribute types.

```ruby
class exampledefault{
  $default_attributes = {
    'ensure' => 'file',
    'owner'  => 'root',
    'group'  => 'wheel'
    'mode'   => '0644',
  }
  $files = [ 'file1', 'file2', 'file3', 'file4' ]
  file {
    default:
      * => $default_attributes,
    ;
    $files:
    ; 
  }
}
```

*Using for each*
```ruby
class exampledefault{
  $default_attributes = {
    'ensure' => 'file',
    'owner'  => 'root',
    'group'  => 'wheel'
    'mode'   => '0644',
  }
  $files = [ 'file1', 'file2', 'file3', 'file4' ]
  file {
    default:
      * => $default_attributes,
    ;
    
    $files.each |path|:
    ;
    
  }
} 

```
### Conditionals:

```ruby
class filemode {
  $file_mode = ${facts['operatingsystem']} ? {
    'debian' => '0644',
    'redhat' => '0666',
    'suse'   => '0777',
    default  => '0666',
  }
  
  file { '/var/lin/mysql.txt':
    ensure => present,
    mode   => $file_mode,
  }
}

```



### Notes for future:
using template() and epp() function to read the tempaltes
