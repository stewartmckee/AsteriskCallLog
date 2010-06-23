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

ActiveRecord::Schema.define(:version => 20090921175537) do

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
    t.integer  "duration",    :limit => 11
    t.integer  "billsec",     :limit => 11
    t.string   "disposition"
    t.string   "amaflag"
    t.string   "uniqueid"
    t.string   "userfield"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "homes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
