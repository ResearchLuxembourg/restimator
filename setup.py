from setuptools import setup, find_packages

setup(
    name='COVID-19 Reproduction Number',
    version='0.0.1',
    url='https://github.com/ResearchLuxembourg/covid-19_reproductionNumber',
    author='Research Luxembourg WP6',
    author_email='lcsb-r3@uni.lu',
    description='Estimator for COVID-19 R(t)',
    install_requires=[
        'pandas ',
        'numpy ',
        'datetime ',
        'matplotlib ',
        'scipy ',
        'openpyxl'
    ],
    packages=find_packages(),
)
