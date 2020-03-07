extends KSButtonPressable


class_name ButtonLockMode


onready var block_lock_system = get_node("/root/Main/BlockLockSystem")


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	toggle_lock_mode()


func toggle_lock_mode():
	block_lock_system.update_blocks(is_on)


func lock():
	block_lock_system.update_blocks(true)


func unlock():
	block_lock_system.update_blocks(false)
