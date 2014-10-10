# CareBert
[![Gem Version](https://badge.fury.io/rb/care_bert.svg)](http://badge.fury.io/rb/care_bert)
[![Build Status](https://travis-ci.org/loybert/care_bert.svg?branch=master)](https://travis-ci.org/loybert/care_bert)

This project rocks and uses MIT-LICENSE.

Any features missing? write your suggestions as issue or create a pull-request.

## Usage

### Overview of provided Rake Tasks

```shell
rake -T

rake care_bert:missing_assocs      # Checks all belongs_to-associations of all instances and checks presence of model if foreign-key is set
rake care_bert:table_integrity     # Tries to load all instances and tracks failures on load
rake care_bert:validate_models     # Run model validations on all model records in database
```


### care\_bert:table\_integrity
Tries to load all instances and tracks failures on load. This might occur, if there is invalid data on a serialized field (e.g. Hash) that can't be loaded by ActiveRecord.

**It is strongly recommended to perform this rake task before any other one.**

```shell
rake care_bert:table_integrity

-- records - broken instances - model --
      5182 -                0 - Tweet
       314 -                0 - Photo
       278 -                0 - User
```


### care\_bert:missing\_assocs
Checks all belongs_to-associations of all instances and checks presence of model if foreign-key is set.

```shell
rake care_bert:missing_assocs

Daniel-DL-1307:paij-backend danielloy$ rake care_bert:missing_assocs
-- records - broken instances - model --
      5182 -                0 - Tweet
       314 -                1 - Photo
       278 -                0 - User

Listing ids of missing model-instances of assocs:
-------------------------------------------------------
- Photo --------------
>> affected_instances: [1]
 -  1    >> {:user=>1231234}
```

### care\_bert:validate\_models
Run model validations on all model records in database. Sums up all ids of failing models by the combined validation-errors.

       
       
```shell
rake care_bert:validate_models

-- records - broken instances - model --
      5182 -                0 - Tweet
       314 -                0 - Photo
       278 -                7 - User

User: 
["Name is missing"] >> [18, 42, 58, 95]
["Name is missing", "E-Mail contains invalid characters"] >> [12, 128, 229]
```



## Agenda

- [ ] Add Tests (with edge cases, securing rails3 and rails4 compat)
- [ ] integrate Travis CI
- [ ] fancy badges..
- [ ] \(optional:) create tasks, that delete troubling model-instances
- [ ] apply rubocop via git-hook
- [ ] apply generic primary_key as lookup instead of static "id"


## Credits

This gem is also inspired from: http://blog.hasmanythrough.com/2006/8/27/validate-all-your-records
https://github.com/joshsusser

