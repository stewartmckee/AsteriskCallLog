# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100728222743) do

  create_table "cdr_entries", :force => true do |t|
    t.string   "accountcode"
    t.string   "src"
    t.string   "dst"
    t.string   "dcontext"
    t.string   "clid"
    t.string   "channel"
    t.string   "dstchannel"
    t.string   "lastapp"
    t.string   "lastdata"
    t.datetime "calldate"
    t.datetime "answerdate"
    t.datetime "hangupdate"
    t.integer  "duration"
    t.integer  "billsec"
    t.string   "disposition"
    t.string   "amaflag"
    t.string   "uniqueid"
    t.string   "userfield"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_number"
  end

  create_table "homes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "extension"
    t.string   "fullname"
    t.boolean  "admin",                                    :default => false
    t.boolean  "account_manager",                          :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
