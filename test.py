# Created by vlad.eganov@gmail.com
# Modified by zhe.dan28@gmail.com

#!/usr/bin/python3

from colorama import Fore
from colorama import Style
from subprocess import Popen
from subprocess import PIPE
import sys


def run_tests(target, tests_file, detailed_info_enable=True):
    with open(tests_file, 'r', encoding='ascii') as f:
        for line in f.readlines():
            args = line.split('=')[0].split()
            answer = line.split('=')[1].strip()
            with Popen([ target ] + args, stdout=PIPE) as proc:
                stdout = proc.stdout.read()
                stdout = stdout.decode('ascii')
                stdout = stdout.replace('\n', '')
                if stdout != answer:
                    print(Fore.RED + 'FAILED ', end='')
                    print(f'Test on args: {args} failed. Stdout: {stdout} != Answer: {answer}')
                else:
                    print(Fore.GREEN + 'OK ', end='' if detailed_info_enable else '\n')
                    if detailed_info_enable:
                        print (f'Args: {args}. Answer: {answer}')

    print(Style.RESET_ALL, end='')


if __name__ == '__main__':
    '''
    To run: python3 test.py {taget_executable} {tests_file}
    Each line of tests file has following structure "test=answer". For example 1 2 -=-1
    "test" in line is parameters for {target_executable}
    '''
    run_tests(*sys.argv[1:])