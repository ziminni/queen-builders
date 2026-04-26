# Generated migration to update role choices

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='role',
            field=models.CharField(
                choices=[
                    ('admin', 'Admin'),
                    ('stockManager', 'Stock Manager'),
                    ('cashier', 'Cashier'),
                    ('projectManager', 'Project Manager'),
                    ('staff', 'Staff'),
                ],
                default='staff',
                max_length=20,
            ),
        ),
    ]
