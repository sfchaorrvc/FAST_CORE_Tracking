class AdminStatusController < ApplicationController
  def up_check
   retval = ActiveRecord::Base.connection.execute('select * from schema_migrations limit 1')
   render(:text => "Site ok @ #{Time::now}, Schema #: #{retval.fetch_row}") && return
  end
end
