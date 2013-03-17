# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130317201655) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "delivery_attempts", :force => true do |t|
    t.integer  "notification_id"
    t.string   "phone_number"
    t.string   "delivery_method"
    t.string   "message_id"
    t.string   "result"
    t.string   "error_type"
    t.text     "error_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.integer  "notifier_id"
  end

  add_index "delivery_attempts", ["delivery_method", "created_at"], :name => "idx_delivery_method_created_at"
  add_index "delivery_attempts", ["notification_id"], :name => "index_delivery_attempts_on_notification_id"

  create_table "intellivr_outbound_messages", :force => true do |t|
    t.integer  "delivery_attempt_id"
    t.string   "ext_message_id"
    t.text     "request"
    t.text     "response"
    t.text     "callback_res"
    t.string   "callee"
    t.integer  "duration"
    t.string   "status"
    t.datetime "connect_at"
    t.datetime "disconnect_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_streams", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_streams", ["name"], :name => "index_message_streams_on_name", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "message_stream_id"
    t.string   "name"
    t.string   "sms_text"
    t.string   "ivr_code"
    t.integer  "offset_days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "language"
    t.integer  "expire_days"
  end

  add_index "messages", ["message_stream_id", "name"], :name => "index_messages_on_message_stream_id_and_name", :unique => true

  create_table "nexmo_inbound_messages", :force => true do |t|
    t.string   "ext_message_id"
    t.integer  "multipart_start_id"
    t.string   "to_msisdn"
    t.string   "mo_tag"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nexmo_inbound_messages", ["ext_message_id"], :name => "index_nexmo_inbound_messages_on_ext_message_id", :unique => true
  add_index "nexmo_inbound_messages", ["multipart_start_id"], :name => "index_nexmo_inbound_messages_on_multipart_start_id"

  create_table "nexmo_outbound_messages", :force => true do |t|
    t.integer  "delivery_attempt_id"
    t.string   "ext_message_id"
    t.string   "to_msisdn"
    t.string   "network_code"
    t.string   "mo_tag"
    t.string   "status"
    t.string   "scts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nexmo_outbound_messages", ["delivery_attempt_id"], :name => "index_nexmo_outbound_messages_on_delivery_attempt_id"
  add_index "nexmo_outbound_messages", ["ext_message_id"], :name => "index_nexmo_outbound_messages_on_ext_message_id", :unique => true

  create_table "notifications", :force => true do |t|
    t.string   "uuid"
    t.integer  "notifier_id"
    t.integer  "message_id"
    t.string   "first_name"
    t.string   "phone_number"
    t.string   "delivery_method"
    t.datetime "delivery_start"
    t.datetime "delivery_expires"
    t.integer  "delivery_window"
    t.string   "status"
    t.string   "last_error_type"
    t.text     "last_error_msg"
    t.datetime "last_run_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delivered_at"
    t.text     "variables"
  end

  add_index "notifications", ["last_run_at", "notifier_id"], :name => "index_notifications_on_last_run_at_and_notifier_id"
  add_index "notifications", ["notifier_id", "uuid"], :name => "index_notifications_on_notifier_id_and_uuid", :unique => true

  create_table "notifiers", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "timezone"
    t.datetime "last_login_at"
    t.datetime "last_status_req_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "active",             :default => true
  end

  add_index "notifiers", ["username"], :name => "index_notifiers_on_username", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",     :default => "en"
    t.string   "name"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
