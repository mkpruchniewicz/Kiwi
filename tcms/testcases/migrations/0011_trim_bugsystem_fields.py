# Generated by Django 2.2.4 on 2019-08-16 12:17

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('testcases', '0010_remove_bug'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='bugsystem',
            name='description',
        ),
        migrations.RemoveField(
            model_name='bugsystem',
            name='url_reg_exp',
        ),
        migrations.RemoveField(
            model_name='bugsystem',
            name='validate_reg_exp',
        ),
    ]