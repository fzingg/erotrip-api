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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180205125132) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"
  enable_extension "unaccent"
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "postgis"

  create_table "access_permissions", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "permitted_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotline_id"
    t.boolean "private_photos_granted", default: false
    t.boolean "profile_granted", default: false
    t.boolean "hotline_granted", default: false
    t.boolean "hotline_requested", default: false
    t.boolean "private_photos_requested", default: false
    t.boolean "profile_requested", default: false
  end

  create_table "alerts", force: :cascade do |t|
    t.string "reason"
    t.text "comment"
    t.boolean "is_viewed", default: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.integer "reported_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_by_id"], name: "index_alerts_on_reported_by_id"
    t.index ["resource_type", "resource_id"], name: "index_alerts_on_resource_type_and_resource_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "desc"
    t.string "photo_uploader"
    t.jsonb "kinds"
    t.integer "all_users_count", default: 0, null: false
    t.integer "private_users_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hotline_access_permissions", force: :cascade do |t|
    t.integer "hotline_id"
    t.integer "owner_id"
    t.integer "permitted_id"
    t.boolean "is_permitted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hotline_id"], name: "index_hotline_access_permissions_on_hotline_id"
    t.index ["is_permitted"], name: "index_hotline_access_permissions_on_is_permitted"
    t.index ["owner_id"], name: "index_hotline_access_permissions_on_owner_id"
    t.index ["permitted_id"], name: "index_hotline_access_permissions_on_permitted_id"
  end

  create_table "hotlines", force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.boolean "is_anonymous", default: false
    t.decimal "lat", precision: 15, scale: 10
    t.decimal "lon", precision: 15, scale: 10
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_hotlines_on_user_id"
  end

  create_table "hyperloop_connections", force: :cascade do |t|
    t.string "channel"
    t.string "session"
    t.datetime "created_at"
    t.datetime "expires_at"
    t.datetime "refresh_at"
  end

  create_table "hyperloop_queued_messages", force: :cascade do |t|
    t.text "data"
    t.integer "connection_id"
  end

  create_table "interests", force: :cascade do |t|
    t.string "title"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content"
    t.integer "plain_user_id"
    t.string "file_uploader"
    t.string "system_kind"
    t.index ["room_id"], name: "index_messages_on_room_id"
    t.index ["system_kind"], name: "index_messages_on_system_kind"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_newsletter_subscriptions_on_email", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_uploader"
    t.boolean "is_private", default: false
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "room_users", force: :cascade do |t|
    t.integer "room_id"
    t.integer "user_id"
    t.integer "unread_counter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_room_users_on_archived_at"
    t.index ["room_id"], name: "index_room_users_on_room_id"
    t.index ["unread_counter"], name: "index_room_users_on_unread_counter"
    t.index ["user_id"], name: "index_room_users_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "last_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trip_id"
    t.integer "hotline_id"
    t.integer "room_id"
    t.integer "owner_id"
    t.index ["hotline_id"], name: "index_rooms_on_hotline_id"
    t.index ["last_message_id"], name: "index_rooms_on_last_message_id"
    t.index ["owner_id"], name: "index_rooms_on_owner_id"
    t.index ["room_id"], name: "index_rooms_on_room_id"
    t.index ["trip_id"], name: "index_rooms_on_trip_id"
  end

  create_table "trip_access_permissions", force: :cascade do |t|
    t.integer "trip_id"
    t.integer "owner_id"
    t.integer "permitted_id"
    t.integer "is_permitted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_permitted"], name: "index_trip_access_permissions_on_is_permitted"
    t.index ["owner_id"], name: "index_trip_access_permissions_on_owner_id"
    t.index ["permitted_id"], name: "index_trip_access_permissions_on_permitted_id"
    t.index ["trip_id"], name: "index_trip_access_permissions_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "arrival_time"
    t.jsonb "destinations", default: []
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_anonymous"
    t.index ["destinations"], name: "index_trips_on_destinations"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.boolean "is_public", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_visit_at"
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["is_public"], name: "index_user_groups_on_is_public"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "user_interests", force: :cascade do |t|
    t.bigint "interest_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interest_id"], name: "index_user_interests_on_interest_id"
    t.index ["user_id"], name: "index_user_interests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "kind"
    t.string "name"
    t.integer "birth_year"
    t.string "name_second_person"
    t.integer "birth_year_second_person"
    t.string "city"
    t.integer "pin"
    t.boolean "terms_acceptation"
    t.string "email"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "is_private", default: false
    t.jsonb "searched_kinds"
    t.integer "weight"
    t.integer "height"
    t.string "body"
    t.boolean "is_smoker", default: false
    t.boolean "is_drinker", default: false
    t.string "avatar_uploader"
    t.string "verification_photo"
    t.string "my_expectations"
    t.text "about_me"
    t.text "likes"
    t.text "dislikes"
    t.text "ideal_partner"
    t.boolean "is_verified", default: false
    t.boolean "is_admin", default: false
    t.decimal "lon", precision: 15, scale: 10
    t.decimal "lat", precision: 15, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rejection_message", limit: 255
    t.string "verification_photo_uploader"
    t.integer "photos_count", default: 0, null: false
    t.datetime "verified_at"
    t.jsonb "privacy_settings", default: {"show_age"=>true, "show_date"=>true, "show_groups"=>true, "show_online"=>true, "show_visits"=>true, "show_gallery"=>true}
    t.jsonb "notification_settings", default: {"on_fit"=>{"email"=>true, "browser"=>true}, "on_like"=>{"email"=>true, "browser"=>true}, "on_guest"=>{"email"=>true, "browser"=>true}, "on_other"=>{"email"=>true, "browser"=>true}, "on_message"=>{"email"=>true, "browser"=>true}, "enable_sound"=>true}
    t.datetime "active_since"
    t.datetime "inactive_since"
    t.datetime "last_users_visit_at"
    t.datetime "last_peepers_visit_at"
    t.datetime "last_trips_visit_at"
    t.datetime "avatar_updated_at"
    t.datetime "verification_photo_updated_at"
    t.jsonb "predefined_users"
    t.jsonb "predefined_trips"
    t.jsonb "predefined_hotline"
    t.index ["body"], name: "index_users_on_body"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_drinker"], name: "index_users_on_is_drinker"
    t.index ["is_private"], name: "index_users_on_is_private"
    t.index ["is_verified"], name: "index_users_on_is_verified"
    t.index ["kind"], name: "index_users_on_kind"
    t.index ["last_peepers_visit_at"], name: "index_users_on_last_peepers_visit_at"
    t.index ["last_trips_visit_at"], name: "index_users_on_last_trips_visit_at"
    t.index ["last_users_visit_at"], name: "index_users_on_last_users_visit_at"
    t.index ["pin"], name: "index_users_on_pin"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["terms_acceptation"], name: "index_users_on_terms_acceptation"
    t.index ["verified_at"], name: "index_users_on_verified_at"
  end

  create_table "visits", force: :cascade do |t|
    t.integer "visitee_id"
    t.integer "visitor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "want_to_meets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "want_to_meet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted_by_want_to_meet", default: false
    t.index ["user_id"], name: "index_want_to_meets_on_user_id"
    t.index ["want_to_meet_id"], name: "index_want_to_meets_on_want_to_meet_id"
  end

  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "updated_by_id"
end
