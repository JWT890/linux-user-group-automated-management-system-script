#!/usr/bin/env python3
import argparse
import os
import sys
import subprocess
from datetime import datetime
import logging

LOG_FILE = "user_mgmt.log1"

def log_action():
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"timestamp) - (message)")

def create_user():
    if 

def delete_user():


def check_groups():


def check_permissions():
    

if __name__="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('username', help='Username to create')
