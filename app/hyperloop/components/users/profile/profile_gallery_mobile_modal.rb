class ProfileGalleryMobileModal < Hyperloop::Component
  include BaseModal

  # param photos: nil
  param user: nil
  param photos_size: nil
  param selected_photo_index: nil
  param can_edit_profile: nil
  param private_photos_permitted: nil
  param opened: true

  state selected_photo_index: nil
  state gallery_opened: false
  state photos_size: nil

  before_mount do
    mutate.selected_photo_index params.selected_photo_index
    mutate.photos_size params.photos_size
  end

  def title
    ''
  end

  def render_modal
    div(class: "profile-gallery-wrapper-modal") do
      photos_scope = Photo.where_user(params.user.try(:id)).order_by_privacy
      div(class: 'profile-gallery-mobile-modal-body modal-body') do
        # GallerySlider(
        # user: params.user,
        # photos_size: state.photos_size,
        # selected_photo_index: state.selected_photo_index,
        # can_edit_profile: true,
        # private_photos_permitted: params.private_photos_permitted,
        # opened: true,
        # onClose: proc { mutate.gallery_opened false },
        # onDelete: proc { |index| delete_current_photo(index, photos_scope) },
        # onModeChange: proc { |photo| update_photo_mode(photo) },
        # onPhotoChange: proc { |index| update_photo_index(index) }
        # )

        GallerySlider(
          user: params.user,
          photos_size: params.photos_size,
          selected_photo_index: state.selected_photo_index,
          can_edit_profile: params.can_edit_profile,
          private_photos_permitted: params.private_photos_permitted,
          onDelete: proc { |index| delete_current_photo(index, photos_scope) },
          onModeChange: proc { |photo| update_photo_mode(photo) },
          onPhotoChange: proc { |index| update_photo_index(index) },
          onClose: proc { mutate.gallery_opened false },
        )
      end
    end
  end

  def update_photo_index index
    if state.selected_photo_index != index
      mutate.selected_photo_index index
    end
  end

  def update_photo_mode photo, e = nil
    if e
      e.stop_propagation
    end

    next_mode = (photo.is_private ? "publiczne" : "prywatne")
    UpdatePhotoMode.run({
      photo_id: photo.id
    })
    .fail do |e|
      handle_errors(e)
    end
  end

  def delete_current_photo index, photos_scope, e = nil
    if e
      e.stop_propagation
    end
    size = state.photos_size
    DeleteUserPhoto.run({
      photo_id: photos_scope[index]["id"]
    })
    .then do |response|
      size = size - 1
      # mutate.blocking(false)
      mutate.photos_size(size)
      react_to_photo_deletion(index, size)
    end
    .fail do |e|
      # mutate.blocking(false)
      handle_errors(e)
    end
  end

  def react_to_photo_deletion(index, size = state.photos_size)
    puts "ROBIE COS"
    # switch to near photo
    last_index = size - 1

    puts "LASTINDEX #{last_index}"
    if index > last_index
      mutate.selected_photo_index(last_index)
      puts "SELETED INDEX #{last_index}"
    else
      mutate.selected_photo_index(index)
    end
  end
end