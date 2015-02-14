#include "generated.h"
#include "GL/gl.h"

inline uint32_t _type_size(GLenum type){
    uint32_t item_size = type == GL_BYTE
        ? sizeof(GLbyte)
        : type == GL_UNSIGNED_BYTE
        ? sizeof(GLubyte)
        : type == GL_SHORT
        ? sizeof(GLshort)
        : type == GL_UNSIGNED_SHORT
        ? sizeof(GLushort)
        : type == GL_INT
        ? sizeof(GLint)
        : type == GL_UNSIGNED_INT
        ? sizeof(GLuint)
        : type == GL_FLOAT
        ? sizeof(GLfloat)
        : type == GL_2_BYTES
        ? sizeof(GLbyte) * 2
        : type == GL_3_BYTES
        ? sizeof(GLbyte) * 3
        : type == GL_4_BYTES
        ? sizeof(GLbyte) * 4
        : 0;
    if(!item_size) {
        LOG("Cannot determine list item size for type %d\n", type);
        abort();
    }
}

uint32_t glPolygonStipple_mask_size(const GLubyte * mask){
    return sizeof(GLubyte) * 32 * 32;
}

uint32_t glEdgeFlagv_flag_size(const GLboolean * flag){
    return sizeof(GLboolean);
}

uint32_t glClipPlane_equation_size(GLenum plane, const GLdouble * equation){
    return sizeof(GLdouble) * 4;
}

uint32_t glLoadMatrixd_m_size(const GLdouble * m){
    return sizeof(GLdouble) * 16;
}

uint32_t glLoadMatrixf_m_size(const GLfloat * m){
    return sizeof(GLfloat) * 16;
}

uint32_t glMultMatrixd_m_size(const GLdouble * m){
    return sizeof(GLdouble) * 16;
}
uint32_t glMultMatrixf_m_size(const GLfloat * m){
    return sizeof(GLfloat) * 16;
}
uint32_t glCallLists_lists_size(GLsizei n, GLenum type, const GLvoid * lists){
    return _type_size(type) * n;
}

uint32_t glVertex2dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 2;
}

uint32_t glVertex2fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 2;
}

uint32_t glVertex2iv_v_size(const GLint * v){
    return sizeof(GLint) * 2 ;
}

uint32_t glVertex2sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 2;
}

uint32_t glVertex3dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 3;
}

uint32_t glVertex3fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 3;
}

uint32_t glVertex3iv_v_size(const GLint * v){
    return sizeof(GLint) * 3;
}

uint32_t glVertex3sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 3;
}

uint32_t glVertex4dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 4;
}

uint32_t glVertex4fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 4;
}

uint32_t glVertex4iv_v_size(const GLint * v){
    return sizeof(GLint) * 4;
}

uint32_t glVertex4sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 4;
}

uint32_t glNormal3bv_v_size(const GLbyte * v){
    return sizeof(GLbyte) * 3;
}

uint32_t glNormal3dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 3;
}

uint32_t glNormal3fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 3;
}

uint32_t glNormal3iv_v_size(const GLint * v){
    return sizeof(GLint) * 3;
}

uint32_t glNormal3sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 3;
}

uint32_t glIndexdv_c_size(const GLdouble * c){
    return sizeof(GLdouble);
}

uint32_t glIndexfv_c_size(const GLfloat * c){
    return sizeof(GLfloat);
}

uint32_t glIndexiv_c_size(const GLint * c){
    return sizeof(GLint);
}

uint32_t glIndexsv_c_size(const GLshort * c){
    return sizeof(GLshort);
}

uint32_t glIndexubv_c_size(const GLubyte * c){
    return sizeof(GLubyte);
}

uint32_t glColor3bv_v_size(const GLbyte * v){
    return sizeof(GLbyte) * 3;
}

uint32_t glColor3dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 3;
}

uint32_t glColor3fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 3;
}

uint32_t glColor3iv_v_size(const GLint * v){
    return sizeof(GLint) * 3;
}

uint32_t glColor3sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 3;
}

uint32_t glColor3ubv_v_size(const GLubyte * v){
    return sizeof(GLubyte) * 3;
}

uint32_t glColor3uiv_v_size(const GLuint * v){
    return sizeof(GLuint) * 3;
}

uint32_t glColor3usv_v_size(const GLushort * v){
    return sizeof(GLushort) * 3;
}

uint32_t glColor4bv_v_size(const GLbyte * v){
    return sizeof(GLbyte) * 4;
}

uint32_t glColor4dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 4;
}

uint32_t glColor4fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 4;
}

uint32_t glColor4iv_v_size(const GLint * v){
    return sizeof(GLint) * 4;
}

uint32_t glColor4sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 4;
}

uint32_t glColor4ubv_v_size(const GLubyte * v){
    return sizeof(GLubyte) * 4;
}

uint32_t glColor4uiv_v_size(const GLuint * v){
    return sizeof(GLuint) * 4;
}

uint32_t glColor4usv_v_size(const GLushort * v){
    return sizeof(GLushort) * 4;
}

uint32_t glTexCoord1dv_v_size(const GLdouble * v){
    return sizeof(GLdouble);
}

uint32_t glTexCoord1fv_v_size(const GLfloat * v){
    return sizeof(GLfloat);
}

uint32_t glTexCoord1iv_v_size(const GLint * v){
    return sizeof(GLint);
}

uint32_t glTexCoord1sv_v_size(const GLshort * v){
    return sizeof(GLshort);
}

uint32_t glTexCoord2dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 2;
}

uint32_t glTexCoord2fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 2;
}

uint32_t glTexCoord2iv_v_size(const GLint * v){
    return sizeof(GLint) * 2;
}

uint32_t glTexCoord2sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 2;
}

uint32_t glTexCoord3dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 3;
}

uint32_t glTexCoord3fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 3;
}

uint32_t glTexCoord3iv_v_size(const GLint * v){
    return sizeof(GLint) * 3;
}

uint32_t glTexCoord3sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 3;
}

uint32_t glTexCoord4dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 4;
}

uint32_t glTexCoord4fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 4;
}

uint32_t glTexCoord4iv_v_size(const GLint * v){
    return sizeof(GLint) * 4;
}

uint32_t glTexCoord4sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 4;
}

uint32_t glRasterPos2dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 2;
}

uint32_t glRasterPos2fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 2;
}

uint32_t glRasterPos2iv_v_size(const GLint * v){
    return sizeof(GLint) * 2;
}

uint32_t glRasterPos2sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 2;
}

uint32_t glRasterPos3dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 3;
}

uint32_t glRasterPos3fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 3;
}

uint32_t glRasterPos3iv_v_size(const GLint * v){
    return sizeof(GLint) * 3;
}

uint32_t glRasterPos3sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 3;
}

uint32_t glRasterPos4dv_v_size(const GLdouble * v){
    return sizeof(GLdouble) * 4;
}

uint32_t glRasterPos4fv_v_size(const GLfloat * v){
    return sizeof(GLfloat) * 4;
}

uint32_t glRasterPos4iv_v_size(const GLint * v){
    return sizeof(GLint) * 4;
}

uint32_t glRasterPos4sv_v_size(const GLshort * v){
    return sizeof(GLshort) * 4;
}

uint32_t glRectdv_v1_size(const GLdouble * v1, const GLdouble * v2){
    return sizeof(GLdouble) * 2;
}

uint32_t glRectdv_v2_size(const GLdouble * v1, const GLdouble * v2){
    return sizeof(GLdouble) * 2;
}

uint32_t glRectfv_v1_size(const GLfloat * v1, const GLfloat * v2){
    return sizeof(GLfloat) * 2;
}

uint32_t glRectfv_v2_size(const GLfloat * v1, const GLfloat * v2){
    return sizeof(GLfloat) * 2;
}

uint32_t glRectiv_v1_size(const GLint * v1, const GLint * v2){
    return sizeof(GLint) * 2;
}

uint32_t glRectiv_v2_size(const GLint * v1, const GLint * v2){
    return sizeof(GLint) * 2;
}

uint32_t glRectsv_v1_size(const GLshort * v1, const GLshort * v2){
    return sizeof(GLshort) * 2;
}

uint32_t glRectsv_v2_size(const GLshort * v1, const GLshort * v2){
    return sizeof(GLshort) * 2;
}

uint32_t glVertexPointer_ptr_size(GLint size, GLenum type, GLsizei stride, const GLvoid * ptr){ abort(); };
uint32_t glNormalPointer_ptr_size(GLenum type, GLsizei stride, const GLvoid * ptr){ abort(); };
uint32_t glColorPointer_ptr_size(GLint size, GLenum type, GLsizei stride, const GLvoid * ptr){ abort(); }
uint32_t glIndexPointer_ptr_size(GLenum type, GLsizei stride, const GLvoid * ptr){ abort(); }
uint32_t glTexCoordPointer_ptr_size(GLint size, GLenum type, GLsizei stride, const GLvoid * ptr){ abort(); }
uint32_t glEdgeFlagPointer_ptr_size(GLsizei stride, const GLvoid * ptr){ abort(); }
uint32_t glDrawElements_indices_size(GLenum mode, GLsizei count, GLenum type, const GLvoid * indices){ abort(); }
uint32_t glInterleavedArrays_pointer_size(GLenum format, GLsizei stride, const GLvoid * pointer){ abort(); }
uint32_t glLightfv_params_size(GLenum light, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glLightiv_params_size(GLenum light, GLenum pname, const GLint * params){ abort(); }
uint32_t glLightModelfv_params_size(GLenum pname, const GLfloat * params){ abort(); }
uint32_t glLightModeliv_params_size(GLenum pname, const GLint * params){ abort(); }
uint32_t glMaterialfv_params_size(GLenum face, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glMaterialiv_params_size(GLenum face, GLenum pname, const GLint * params){ abort(); }
uint32_t glPixelMapfv_values_size(GLenum map, GLsizei mapsize, const GLfloat * values){ abort(); }
uint32_t glPixelMapuiv_values_size(GLenum map, GLsizei mapsize, const GLuint * values){ abort(); }
uint32_t glPixelMapusv_values_size(GLenum map, GLsizei mapsize, const GLushort * values){ abort(); }
uint32_t glBitmap_bitmap_size(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte * bitmap){ abort(); }
uint32_t glDrawPixels_pixels_size(GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glTexGendv_params_size(GLenum coord, GLenum pname, const GLdouble * params){ abort(); }
uint32_t glTexGenfv_params_size(GLenum coord, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glTexGeniv_params_size(GLenum coord, GLenum pname, const GLint * params){ abort(); }
uint32_t glTexEnvfv_params_size(GLenum target, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glTexEnviv_params_size(GLenum target, GLenum pname, const GLint * params){ abort(); }
uint32_t glTexParameterfv_params_size(GLenum target, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glTexParameteriv_params_size(GLenum target, GLenum pname, const GLint * params){ abort(); }
uint32_t glTexImage1D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glTexImage2D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glDeleteTextures_textures_size(GLsizei n, const GLuint * textures){ abort(); }
uint32_t glPrioritizeTextures_textures_size(GLsizei n, const GLuint * textures, const GLclampf * priorities){ abort(); }
uint32_t glPrioritizeTextures_priorities_size(GLsizei n, const GLuint * textures, const GLclampf * priorities){ abort(); }
uint32_t glAreTexturesResident_textures_size(GLsizei n, const GLuint * textures, GLboolean * residences){ abort(); }
uint32_t glTexSubImage1D_pixels_size(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glTexSubImage2D_pixels_size(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glMap1d_points_size(GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble * points){ abort(); }
uint32_t glMap1f_points_size(GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat * points){ abort(); }
uint32_t glMap2d_points_size(GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble * points){ abort(); }
uint32_t glMap2f_points_size(GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat * points){ abort(); }
uint32_t glEvalCoord1dv_u_size(const GLdouble * u){ abort(); }
uint32_t glEvalCoord1fv_u_size(const GLfloat * u){ abort(); }
uint32_t glEvalCoord2dv_u_size(const GLdouble * u){ abort(); }
uint32_t glEvalCoord2fv_u_size(const GLfloat * u){ abort(); }
uint32_t glFogfv_params_size(GLenum pname, const GLfloat * params){ abort(); }
uint32_t glFogiv_params_size(GLenum pname, const GLint * params){ abort(); }
uint32_t glDrawRangeElements_indices_size(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const GLvoid * indices){ abort(); }
uint32_t glTexImage3D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glTexSubImage3D_pixels_size(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const GLvoid * pixels){ abort(); }
uint32_t glColorTable_table_size(GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid * table){ abort(); }
uint32_t glColorSubTable_data_size(GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum type, const GLvoid * data){ abort(); }
uint32_t glColorTableParameteriv_params_size(GLenum target, GLenum pname, const GLint * params){ abort(); }
uint32_t glColorTableParameterfv_params_size(GLenum target, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glConvolutionFilter1D_image_size(GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid * image){ abort(); }
uint32_t glConvolutionFilter2D_image_size(GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid * image){ abort(); }
uint32_t glConvolutionParameterfv_params_size(GLenum target, GLenum pname, const GLfloat * params){ abort(); }
uint32_t glConvolutionParameteriv_params_size(GLenum target, GLenum pname, const GLint * params){ abort(); }
uint32_t glSeparableFilter2D_row_size(GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid * row, const GLvoid * column){ abort(); }
uint32_t glSeparableFilter2D_column_size(GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid * row, const GLvoid * column){ abort(); }
uint32_t glCompressedTexImage1D_data_size(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glCompressedTexImage2D_data_size(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glCompressedTexImage3D_data_size(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glCompressedTexSubImage1D_data_size(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glCompressedTexSubImage2D_data_size(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glCompressedTexSubImage3D_data_size(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const GLvoid * data){ abort(); }
uint32_t glMultiTexCoord1dv_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord1fv_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord1iv_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord1sv_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord2dv_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord2fv_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord2iv_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord2sv_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord3dv_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord3fv_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord3iv_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord3sv_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord4dv_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord4fv_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord4iv_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord4sv_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord1dvARB_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord1fvARB_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord1ivARB_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord1svARB_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord2dvARB_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord2fvARB_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord2ivARB_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord2svARB_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord3dvARB_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord3fvARB_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord3ivARB_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord3svARB_v_size(GLenum target, const GLshort * v){ abort(); }
uint32_t glMultiTexCoord4dvARB_v_size(GLenum target, const GLdouble * v){ abort(); }
uint32_t glMultiTexCoord4fvARB_v_size(GLenum target, const GLfloat * v){ abort(); }
uint32_t glMultiTexCoord4ivARB_v_size(GLenum target, const GLint * v){ abort(); }
uint32_t glMultiTexCoord4svARB_v_size(GLenum target, const GLshort * v){ abort(); }
