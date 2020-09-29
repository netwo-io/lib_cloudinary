-- library for cloudinary

drop schema if exists lib_cloudinary cascade;
create schema lib_cloudinary;
grant usage on schema lib_cloudinary to public;
set search_path = pg_catalog;

\ir cloudinary.sql
