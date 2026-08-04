#ifndef TLM_MM_H
#define TLM_MM_H

/**
 * @file tlm_mm.h
 * @brief TLM 2.0 Memory Manager for Generic Payload
 */

#include <tlm>
#include <vector>

namespace ethernet_tlm {

/**
 * @class tlm_mm
 * @brief 简单的 TLM generic payload 内存管理器
 */
class tlm_mm : public tlm::tlm_mm_interface {
public:
    tlm_mm() = default;
    ~tlm_mm() = default;

    void free(tlm::tlm_generic_payload* trans) override {
        delete trans;
    }

    static tlm_mm& instance() {
        static tlm_mm inst;
        return inst;
    }
};

} // namespace ethernet_tlm

#endif // TLM_MM_H
