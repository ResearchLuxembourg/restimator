FROM julia

ADD Project.toml *.jl lib /tool/
WORKDIR /tool

RUN julia --project=. -e 'import Pkg; Pkg.instantiate();'

CMD bash
