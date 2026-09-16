# Maxregner Vault (maxregner_vault) — real firmware injection
#
# The 0001-Introduce-MaxregnerVault.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerVault; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real privacy policy
# engine: it reads ro.maxregner.vault.* props, resolves a permission scope
# bitmask from a scope name (location/camera/microphone/contacts/clipboard)
# via scopeFromString(), evaluates whether an idle grant should be auto
# revoked via shouldAutoRevoke(grantTimeMs, nowMs), and classifies whether an
# access hits a sensitive scope via classifySensitivity(appScopes, access).

LOG_STEP_IN "- Injecting Maxregner Vault privacy engine"

# Vault enable flag read by MaxregnerVault.readEnabled().
SET_PROP "system" "ro.maxregner.vault.enabled" "true"
SET_PROP "system" "ro.maxregner.vault.auto_revoke" "true"
SET_PROP "system" "ro.maxregner.vault.auto_revoke_ms" "7200000"
SET_PROP "system" "ro.maxregner.vault.clipboard_guard" "true"
SET_PROP "system" "ro.maxregner.vault.sensor_guard" "true"

LOG_STEP_OUT
