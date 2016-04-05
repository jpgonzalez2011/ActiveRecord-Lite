# ActiveRecord-Lite

## Object Relational Mapping Inspired by Active Record

Uses Ruby to generate SQL query code via meta-programming.

## Demo Instructions

- Clone the repository.
- Navigate into the repository.
- Open irb or pry.
- Load the demo.rb file
```
load 'demo.rb'
```
- Try a command
```
Cat.find(1)
```
- Run methods on c - such as c.human and c.house
- Methods can also be chained.
```
Cat.find(1).human
Cat.find(1).human.house
```

##  Features

- Creates SQL Object Classes relating to database tables.
- Prevents assignment of SQL Object Attributes which do not correspond to table columns.
- Extends SQL Object Class to allow Searching through "WHERE" clause.
- Further extends SQL Object Class to allow Associations through foreign keys.

## Libraries and Gems
- ActiveSupport::Inflector
- SQLite3

## ActiveRecord Methods Available
- ::all
```
Cat.all # => Array of Cats
```
- ::find
```
Cat.find(2) # => Cat with id of 2
```
- ::where
```
Cat.where(name: 'Garfield') #=> Cat named 'Garfield'
```
- #insert
- #save
- #update
- #destroy
