class CreateCdrEntries < ActiveRecord::Migration
  def self.up
    create_table :cdr_entries do |t|
      t.string :accountcode
      t.string :src
      t.string :dst
      t.string :dcontext
      t.string :clid
      t.string :channel
      t.string :dstchannel
      t.string :lastapp
      t.string :lastdata
      t.datetime :calldate
      t.datetime :answerdate
      t.datetime :hangupdate
      t.integer :duration
      t.integer :billsec
      t.string :disposition
      t.string :amaflag
      t.string :uniqueid
      t.string :userfield

      t.timestamps
    end
  end

  def self.down
    drop_table :cdr_entries
  end
end
