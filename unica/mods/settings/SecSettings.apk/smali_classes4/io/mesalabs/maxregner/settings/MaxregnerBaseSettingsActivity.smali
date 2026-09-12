.class public abstract Lio/mesalabs/maxregner/settings/MaxregnerBaseSettingsActivity;
.super Lcom/android/settings/SettingsActivity;
.source "MaxregnerBaseSettingsActivity.java"

# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Lcom/android/settings/SettingsActivity;-><init>()V
    return-void
.end method

.method private isMaxregnerFragment(Ljava/lang/String;)Z
    .locals 1
    if-nez p1, :cond_0
    const/4 p0, 0x0
    return p0
    :cond_0
    const-string v0, "io.mesalabs.maxregner.settings"
    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result p0
    return p0
.end method

# virtual methods
.method public final isValidFragment(Ljava/lang/String;)Z
    .locals 0
    invoke-direct {p0, p1}, Lio/mesalabs/maxregner/settings/MaxregnerBaseSettingsActivity;->isMaxregnerFragment(Ljava/lang/String;)Z
    move-result p0
    return p0
.end method
