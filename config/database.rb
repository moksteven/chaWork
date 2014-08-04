
DataMapper.logger = logger
DataMapper::Property::String.length(255)

case Padrino.env
  when :development then DataMapper.setup(:default, 'mysql://root:123456@localhost/chafree')
  when :production  then DataMapper.setup(:default, 'mysql://root:123456@localhost/chafree')
  when :test        then DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "cha_work_test.db"))
end

#root:smartwebsql
