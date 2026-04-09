import 'package:flutter/material.dart';
import 'package:android_cache_cleaner/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          final version = packageInfo?.version ?? '1.0.0';

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Header with Logo
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/cacheflow.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  l10n.version(version),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.appDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Links Section
              _buildSectionTitle(context, l10n.developer),
              _buildListTile(
                context,
                icon: Icons.language,
                title: 'sahraouilarbi.com',
                subtitle: l10n.officialSite,
                onTap: () => _launchUrl('https://sahraouilarbi.com'),
              ),
              _buildListTile(
                context,
                icon: Icons.email_outlined,
                title: 'contact@sahraouilarbi.com',
                subtitle: l10n.supportContact,
                onTap: () => _launchUrl('mailto:contact@sahraouilarbi.com'),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context, l10n.openSource),
              _buildListTile(
                context,
                icon: Icons.code,
                title: l10n.sourceCodeGithub,
                subtitle: l10n.contributeToProject,
                onTap: () => _launchUrl(
                  'https://github.com/sahraouilarbi/android_cache_cleaner',
                ),
              ),
              _buildListTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () => _launchUrl(
                  'https://sahraouilarbi.github.io/android_cache_cleaner/privacy',
                ),
              ),
              _buildListTile(
                context,
                icon: Icons.description_outlined,
                title: l10n.openSourceLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: version,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/cacheflow.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  applicationLegalese: l10n.copyright,
                ),
              ),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  l10n.madeWithLove,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
