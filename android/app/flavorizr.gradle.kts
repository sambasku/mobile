import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.iamutaki.sambasku.staging"
            resValue(type = "string", name = "app_name", value = "SambasKu Staging")
            manifestPlaceholders["deepLinkHost"] = "sambasku-web-staging.ibnuul.workers.dev"
            // GitHub OAuth custom scheme (terpisah dari prod supaya tidak bentrok).
            manifestPlaceholders["oauthDeepLinkScheme"] = "sambasku-staging"
            manifestPlaceholders["appAuthRedirectScheme"] = "com.iamutaki.sambasku.staging"
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.iamutaki.sambasku"
            resValue(type = "string", name = "app_name", value = "SambasKu")
            manifestPlaceholders["deepLinkHost"] = "sambasku.com"
            manifestPlaceholders["oauthDeepLinkScheme"] = "sambasku"
            manifestPlaceholders["appAuthRedirectScheme"] = "com.iamutaki.sambasku"
        }
    }

    buildFeatures.resValues = true
}
