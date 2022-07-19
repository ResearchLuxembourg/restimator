FROM julia

ADD Project.toml /tool/
ADD components /tool/components
ADD lib /tool/lib
WORKDIR /tool

RUN julia --project=. -e 'import Pkg; Pkg.instantiate();'

# precompile
RUN julia --project=. -e 'using CSV, DataFrames, CairoMakie, XLSX'

CMD bash
