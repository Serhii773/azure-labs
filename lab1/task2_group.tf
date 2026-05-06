# Task 2 - Створення групи
resource "azuread_group" "it_admins" {
  display_name     = "IT Lab Administrators"
  description      = "Administrators that manage the IT lab"
  security_enabled = true

  owners = [data.azuread_client_config.current.object_id]

  members = [
    azuread_user.user1.object_id,
    azuread_invitation.guest.user_id,
  ]
}
