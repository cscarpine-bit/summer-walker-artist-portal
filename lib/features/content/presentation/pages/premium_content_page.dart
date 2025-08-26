import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class PremiumContentPage extends StatelessWidget {
  const PremiumContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Premium Content'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryTextColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
            color: AppTheme.primaryTextColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock Exclusive Content',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get early access to new songs, behind-the-scenes videos, and exclusive content',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription Plans
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Monthly Plan
            _SubscriptionCard(
              title: 'Monthly',
              price: '\$9.99',
              period: 'per month',
              features: const [
                'Access to all premium content',
                'New songs 1 week early',
                'Exclusive behind-the-scenes',
                'HD video quality',
              ],
              isPopular: false,
              onSubscribe: () => _showPaymentDialog(context, 'Monthly', '\$9.99'),
            ),
            
            const SizedBox(height: 16),
            
            // Annual Plan
            _SubscriptionCard(
              title: 'Annual',
              price: '\$99.99',
              period: 'per year',
              features: const [
                'Everything in Monthly',
                '2 months free',
                'Priority customer support',
                'Exclusive merch discounts',
                'Early access to concerts',
              ],
              isPopular: true,
              onSubscribe: () => _showPaymentDialog(context, 'Annual', '\$99.99'),
            ),
            
            const SizedBox(height: 32),
            
            // What's Included
            Text(
              'What\'s Included',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const _FeatureItem(
              icon: Icons.music_note,
              title: 'New Songs & Albums',
              description: 'Get exclusive access to unreleased tracks and early album previews',
              color: AppTheme.primaryColor,
            ),
            
            const _FeatureItem(
              icon: Icons.videocam,
              title: 'Behind-the-Scenes',
              description: 'Exclusive studio sessions, rehearsals, and personal moments',
              color: AppTheme.secondaryColor,
            ),
            
            const _FeatureItem(
              icon: Icons.photo_library,
              title: 'Exclusive Photos',
              description: 'Professional photoshoots and candid moments',
              color: Colors.purple,
            ),
            
            const _FeatureItem(
              icon: Icons.event,
              title: 'Event Access',
              description: 'Early access to concert tickets and VIP experiences',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 24),
            
            // Terms
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Subscription automatically renews. Cancel anytime. Terms and conditions apply.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String plan, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Subscribe to $plan Plan',
          style: const TextStyle(color: AppTheme.primaryTextColor),
        ),
        content: Text(
          'You will be charged $price for the $plan plan. Continue?',
          style: const TextStyle(color: AppTheme.primaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(context, plan, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, String plan, String price) {
    // TODO: Implement actual payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment processing for $plan plan...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    
    // Simulate payment processing
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Future.delayed(const Duration(seconds: 2), () {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Successfully subscribed to $plan plan!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onSubscribe;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isPopular) const SizedBox(height: 16),
          
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                period,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppTheme.primaryColor : AppTheme.surfaceColor,
                foregroundColor: isPopular ? Colors.white : AppTheme.primaryColor,
                side: BorderSide(
                  color: isPopular ? Colors.transparent : AppTheme.primaryColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
