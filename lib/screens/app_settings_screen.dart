import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_settings_provider.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppSettingsProvider>().fetchAppSettings();
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE86A4D),
        foregroundColor: Colors.white,
        title: const Text(
          'App Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<AppSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE86A4D)),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Note: The App Settings API request action was not included in the provided API documentation. This feature may not work until the correct API endpoint is confirmed.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.fetchAppSettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86A4D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.settings == null) {
            return const Center(child: Text('No settings available'));
          }

          final settings = provider.settings!;

          return RefreshIndicator(
            onRefresh: provider.fetchAppSettings,
            color: const Color(0xFFE86A4D),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // App Version Info
                _buildSection('App Version', [
                  _buildInfoTile(
                    Icons.android,
                    'Android Version',
                    settings.appAndroidVersion,
                    subtitle: settings.appAndroidForceUpdate
                        ? 'Force update enabled'
                        : null,
                    subtitleColor: Colors.orange,
                  ),
                  _buildInfoTile(
                    Icons.apple,
                    'iOS Version',
                    settings.appIosVersion,
                    subtitle: settings.appIosForceUpdate
                        ? 'Force update enabled'
                        : null,
                    subtitleColor: Colors.orange,
                  ),
                ]),
                const SizedBox(height: 16),

                // Maintenance Mode
                if (settings.appMaintenanceMode)
                  _buildSection('Maintenance', [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'App is in maintenance mode',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                const SizedBox(height: 16),

                // Update Information
                _buildSection('Update Information', [
                  _buildInfoTile(
                    Icons.system_update_alt,
                    'Update Title',
                    settings.updateTitle,
                  ),
                  _buildInfoTile(
                    Icons.message,
                    'Update Message',
                    settings.updateMessage,
                    maxLines: 3,
                  ),
                ]),
                const SizedBox(height: 16),

                // Contact Information
                _buildSection('Contact Information', [
                  _buildInfoTile(
                    Icons.email,
                    'Support Email',
                    settings.supportEmailId,
                    onTap: () =>
                        _launchUrl('mailto:${settings.supportEmailId}'),
                  ),
                  _buildInfoTile(
                    Icons.alternate_email,
                    'Contact Email',
                    settings.contactEmailId,
                    onTap: () =>
                        _launchUrl('mailto:${settings.contactEmailId}'),
                  ),
                  _buildInfoTile(
                    Icons.phone,
                    'Contact Number',
                    settings.contactNumber,
                    onTap: () => _launchUrl('tel:${settings.contactNumber}'),
                  ),
                  _buildInfoTile(
                    Icons.chat,
                    'WhatsApp',
                    settings.whatsappNumber,
                    onTap: () =>
                        _launchUrl('https://wa.me/${settings.whatsappNumber}'),
                  ),
                ]),
                const SizedBox(height: 16),

                // Store Links
                _buildSection('Store Links', [
                  _buildInfoTile(
                    Icons.shop,
                    'Play Store',
                    'Open in Play Store',
                    onTap: () => _launchUrl(settings.playStoreLink),
                  ),
                  _buildInfoTile(
                    Icons.apple,
                    'App Store',
                    'Open in App Store',
                    onTap: () => _launchUrl(settings.appStoreLink),
                  ),
                ]),
                const SizedBox(height: 16),

                // Legal Links
                _buildSection('Legal', [
                  _buildInfoTile(
                    Icons.description,
                    'Terms & Conditions',
                    'View Terms',
                    onTap: () => _launchUrl(settings.termsAndConditionUrl),
                  ),
                  _buildInfoTile(
                    Icons.privacy_tip,
                    'Privacy Policy',
                    'View Privacy Policy',
                    onTap: () => _launchUrl(settings.privacyUrl),
                  ),
                ]),
                const SizedBox(height: 16),

                // API Keys (Hidden for security)
                _buildSection('Configuration', [
                  _buildInfoTile(
                    Icons.map,
                    'Google Maps API',
                    '••••••••${settings.googleMapApi.substring(settings.googleMapApi.length - 4)}',
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE86A4D),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    String? subtitle,
    Color? subtitleColor,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE86A4D)),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: subtitleColor ?? Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      trailing: onTap != null ? const Icon(Icons.open_in_new, size: 20) : null,
      onTap: onTap,
    );
  }
}
