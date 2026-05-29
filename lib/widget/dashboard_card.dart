import 'package:flutter/material.dart';

class DashboardCard
    extends StatelessWidget {

  final String title;

  final String value;

  final IconData icon;

  final Color color;

  final VoidCallback? onTap;

  const DashboardCard({

    Key? key,

    required this.title,

    required this.value,

    required this.icon,

    required this.color,

    this.onTap,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius:
      BorderRadius.circular(20),

      child: Container(

        padding:
        const EdgeInsets.all(16),

        decoration: BoxDecoration(

          borderRadius:
          BorderRadius.circular(20),

          color:
          color.withOpacity(0.12),

          border: Border.all(

            color:
            color.withOpacity(0.5),

            width: 1.2,
          ),

          boxShadow: [

            BoxShadow(

              color:
              Colors.black
                  .withOpacity(0.05),

              blurRadius: 6,

              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: [

            Row(

              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [

                Icon(

                  icon,

                  color: color,

                  size: 30,
                ),

                Icon(

                  Icons.arrow_forward_ios,

                  size: 16,

                  color:
                  Colors.grey[600],
                ),
              ],
            ),

            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    color:
                    Colors.grey[700],

                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(

                  value,

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,

                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}