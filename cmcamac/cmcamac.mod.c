#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xf8cdd757, "module_layout" },
	{ 0xd7617cd1, "usb_deregister" },
	{ 0x129ac5e6, "usb_register_driver" },
	{ 0x9a76f11f, "__mutex_init" },
	{ 0x3926a2c3, "usb_deregister_dev" },
	{ 0xd090ac19, "usb_register_dev" },
	{ 0x28318305, "snprintf" },
	{ 0xd2b09ce5, "__kmalloc" },
	{ 0x8451aa9d, "usb_get_dev" },
	{ 0xf86c8d03, "kmem_cache_alloc_trace" },
	{ 0x8200293d, "kmalloc_caches" },
	{ 0xa6093a32, "mutex_unlock" },
	{ 0xb348a850, "ex_handler_refcount" },
	{ 0x613c6199, "usb_find_interface" },
	{ 0x41aed6e7, "mutex_lock" },
	{ 0xf9a482f9, "msleep" },
	{ 0x69acdf38, "memcpy" },
	{ 0x27e1a049, "printk" },
	{ 0x60b40fd8, "copy_user_enhanced_fast_string" },
	{ 0xe5772d4a, "copy_user_generic_string" },
	{ 0xdcc3a419, "copy_user_generic_unrolled" },
	{ 0xdb7305a1, "__stack_chk_fail" },
	{ 0xb9ac5c5c, "usb_bulk_msg" },
	{ 0x37a0cba, "kfree" },
	{ 0x64dfa1c6, "usb_put_dev" },
	{ 0xbdfb6dbb, "__fentry__" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

MODULE_ALIAS("usb:v1279p0064d*dc*dsc*dp*ic*isc*ip*in*");

MODULE_INFO(srcversion, "EA1BC604CFDB95BCF6DD00E");
MODULE_INFO(rhelversion, "8.4");
