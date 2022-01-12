from setuptools import setup, find_packages

setup(
    name='COVID-19 Reproduction Number - Check',
    version='0.0.1',
    url='https://github.com/ResearchLuxembourg/covid-19_reproductionNumber',
    author='Research Luxembourg WP6',
    author_email='lcsb-r3@uni.lu',
    description='Check input file for reproduction number pipeline',
    install_requires=[
        'pandas>=1.3.5',
        'numpy>=1.22.0',
        'datetime>=4.3',
        'openpyxl>=3.0.9'
    ],
    packages=find_packages(),
)
