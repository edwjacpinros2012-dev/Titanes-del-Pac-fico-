extends SceneTree

const AccountScript = preload("res://scripts/accounts/account_manager.gd")
const CloudScript = preload("res://scripts/accounts/cloud_sync_manager.gd")
const SettingsScript = preload("res://scripts/core/settings_manager.gd")
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: ", label)

func _run() -> void:
	var account = AccountScript.new()
	root.add_child(account)
	var profile: Dictionary = account.get_profile()
	_check(not str(profile.get("player_id", "")).is_empty(), "local player identity generated")
	_check(profile.get("provider", "") == "offline", "profile starts in offline mode")
	_check(account.set_display_name("Explorador"), "valid display name accepted")
	_check(not account.set_display_name(""), "empty display name rejected")
	_check(not account.set_display_name("x".repeat(25)), "overlong display name rejected")
	account.begin_google_sign_in()
	_check(not account.authenticated, "Google sign-in placeholder does not claim authentication")
	_check(account.complete_provider_sign_in("google", "verified-id"), "verified provider identity accepted by integration seam")
	account.sign_out_to_offline()
	_check(not account.authenticated, "sign-out returns to offline mode")
	var cloud = CloudScript.new()
	_check(not cloud.configure("http://unsafe", "key"), "non-HTTPS cloud endpoint rejected")
	_check(cloud.configure("https://example.invalid", "public-key"), "HTTPS/public client config accepted")
	cloud.set_account_linked(true)
	_check(not cloud.request_sync({"profile":profile}), "cloud sync refuses to fake upload while backend stub is pending")
	var settings = SettingsScript.new()
	root.add_child(settings)
	_check(settings.set_setting("master_volume", 2.0), "setting write succeeds")
	_check(settings.settings["master_volume"] == 1.0, "volume clamps to valid range")
	_check(not settings.set_setting("unexpected", true), "unknown setting rejected")
	_check(settings.settings["privacy_analytics_opt_in"] == false, "analytics consent defaults off")
	print("RESULT: ", passed, " passed; ", failed, " failed")
	quit(1 if failed > 0 else 0)
